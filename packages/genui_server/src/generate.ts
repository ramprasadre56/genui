import { ai, z } from "./genkit";
import { generateUiRequestSchema, Part as ClientPart } from "./schemas";
import { googleAI } from "@genkit-ai/googleai";
import { cacheService, CacheFlowContext } from "./cache";
import { logger } from "./logger";
import { Message, Part } from "@genkit-ai/ai";

const widgetSchema = z.object({
  id: z.string().describe("The unique ID for the widget."),
  widget: z.any().describe("The widget definition."),
});

const uiDefinitionSchema = z.object({
  root: z.string().describe("The ID of the root widget in the UI tree."),
  widgets: z
    .array(widgetSchema)
    .describe("A list of all the widget definitions for this UI surface."),
});

const addOrUpdateSurfaceTool = ai.defineTool(
  {
    name: "addOrUpdateSurface",
    description:
      "Add or update a UI surface. The 'definition' must conform to the JSON schema provided in the system prompt.",
    inputSchema: z.object({
      surfaceId: z.string().describe("The unique ID for the UI surface."),
      definition: uiDefinitionSchema.describe(
        "A JSON object that defines the UI surface."
      ),
    }),
    outputSchema: z.object({ status: z.string() }),
  },
  async (args: object) => {
    logger.debug(`Received tool call with arguments:\n${JSON.stringify(args)}`);
    return { status: "updated" };
  }
);

const deleteSurfaceTool = ai.defineTool(
  {
    name: "deleteSurface",
    description: "Delete a UI surface.",
    inputSchema: z.object({
      surfaceId: z.string().describe("The unique ID for the UI surface."),
    }),
    outputSchema: z.object({ status: z.string() }),
  },
  async () => ({ status: "deleted" })
);

export const generateUiFlow = ai.defineFlow(
  {
    name: "generateUi",
    inputSchema: generateUiRequestSchema,
    outputSchema: z.unknown(),
  },
  async (request, streamingCallback) => {
    const resolvedCache =
      (streamingCallback.context as CacheFlowContext)?.cache || cacheService;

    const catalog = await resolvedCache.getSessionCache(request.sessionId);
    if (!catalog) {
      logger.error(`Invalid session ID: ${request.sessionId}`);
      throw new Error("Invalid session ID");
    }
    logger.debug("Successfully retrieved catalog from cache.");

    // Convert the dynamic catalog (which is a JSON schema) to a string.
    const catalogSchemaString = JSON.stringify(catalog, null, 2);

    // Create a dynamic system prompt that includes the schema. This instructs
    // the model on how to structure the 'definition' parameter for this call.
    const systemPrompt = `
You are an expert UI generation agent. Your goal is to generate a UI based on the user's request.

When you use the 'addOrUpdateSurface' tool, the 'definition' parameter you provide MUST be a JSON object that strictly conforms to the following JSON Schema:
\`\`\`json
${catalogSchemaString}
\`\`\`

After you have successfully called the 'addOrUpdateSurface' tool and have received a 'toolResponse' with a status of 'updated', you should consider the user's request fulfilled. Respond with a short confirmation message to the user and then stop. Do not call the tool again unless the user asks for further changes.
`.trim();

    // Transform conversation to Genkit's format
    const genkitConversation: Message[] = request.conversation.map(
      (message) => {
        const content: Part[] = message.parts
          .map((part: ClientPart): Part | undefined => {
            if (part.type === "text") {
              return { text: part.text };
            }
            if (part.type === "image") {
              if (part.url) {
                const mediaPart: {
                  media: { url: string; contentType?: string };
                } = {
                  media: { url: part.url },
                };
                if (part.mimeType) {
                  mediaPart.media.contentType = part.mimeType;
                }
                return mediaPart;
              }
              if (part.base64 && part.mimeType) {
                const dataUrl = `data:${part.mimeType};base64,${part.base64}`;
                return { media: { url: dataUrl, contentType: part.mimeType } };
              }
            }
            if (part.type === "ui") {
              return {
                toolRequest: {
                  name: "addOrUpdateSurface",
                  input: part.definition,
                },
              };
            }
            if (part.type === "uiEvent") {
              const event = part.event;
              const value = event.value
                ? ` with value ${JSON.stringify(event.value)}`
                : "";
              return {
                text: `The user triggered the '${event.eventType}' event on widget '${event.widgetId}'${value}.`,
              };
            }
            return undefined;
          })
          .filter((p): p is Part => p !== undefined);

        return new Message({
          role: message.role,
          content,
        });
      }
    );

    try {
      logger.debug(
        genkitConversation,
        "Starting AI generation for conversation"
      );
      const { stream, response } = ai.generateStream({
        model: googleAI.model("gemini-2.5-pro"),
        // Add the dynamic system prompt to the generation call.
        system: systemPrompt,
        messages: genkitConversation,
        // Use the statically defined tools.
        tools: [addOrUpdateSurfaceTool, deleteSurfaceTool],
      });

      for await (const chunk of stream) {
        logger.debug({ chunk }, "Chunk from AI");
        // Your existing streaming logic for handling tool requests and
        // text responses remains the same.
        if (chunk.toolRequests) {
          logger.info("Yielding tool request from AI.");
          streamingCallback(chunk);
        }
      }

      const finalResponse = await response;
      if (finalResponse.text) {
        logger.info("Yielding final text response from AI.");
        streamingCallback({ text: finalResponse.text });
      }

      return finalResponse;
    } catch (error) {
      logger.error(error, "An error occurred during AI generation");
      throw error;
    }
  }
);
