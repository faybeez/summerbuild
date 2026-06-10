import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";
import type { Database } from "../database.types.ts";
import OpenAI from "npm:openai@4";

const REKA_API_KEY = Deno.env.get("REKA_API_KEY")!;
console.log("REKA_API_KEY:", REKA_API_KEY);

export default {
  fetch: withSupabase<Database>({ auth: "user" }, async (req, ctx) => {
    const { userClaims } = ctx;

    if (!userClaims) {
      return Response.json({ error: "Unauthorized" }, { status: 401 });
    }

    const formData = await req.formData();
    const image = formData.get("image") as File | null;

    if (!image) {
      return Response.json({ error: "Image is required" }, { status: 400 });
    }

    if (!(image instanceof File)) {
      return Response.json({ error: "Image is invalid" }, { status: 400 });
    }

    const arrayBuffer = await image.arrayBuffer();
    const bytes = new Uint8Array(arrayBuffer);

    let binary = "";
    for (const byte of bytes) {
      binary += String.fromCharCode(byte);
    }

    const base64 = btoa(binary);

    const mimeType = image.type || "image/jpeg";
    const dataUrl = `data:${mimeType};base64,${base64}`;

    // create openai client for REKA api
    // const client = new OpenAI({
    //   baseURL: "https://api.reka.ai/v1",
    //   apiKey: REKA_API_KEY,
    // });

    // const rekaResponse = await client.chat.completions.create({
    //   model: "reka-edge-2603",
    //   messages: [
    //     {
    //       role: "user",
    //       content: [
    //         {
    //           type: "image_url",
    //           image_url: {
    //             url: dataUrl,
    //           },
    //         },
    //         {
    //           type: "text",
    //           text: `Analyze the clothing item in the image.

    //             Return only valid minified JSON. Do not include explanations.

    //             Use this exact schema:
    //             {"main_colors":[],"secondary_colors":[],"occasion":"","category":""}

    //             Rules:
    //             - main_colors must contain 1 or 2 colors only.
    //             - secondary_colors must contain 0 to 4 colors only.
    //             - Each color must be one word only.
    //             - occasion must be exactly one of: Casual, Business, Formal.
    //             - category must be exactly one of: Tops, Pants, Outerwear, Shoes, Dresses, Accessories.
    //             - If uncertain, choose the closest valid option.
    //             - Never return null.
    //             - Never return extra fields.`,
    //         },
    //       ],
    //     },
    //   ],
    // });

    const response = await fetch("https://api.reka.ai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Api-Key": REKA_API_KEY,
      },
      body: JSON.stringify({
        model: "reka-edge",
        messages: [
          {
            role: "user",
            content: [
              {
                type: "image_url",
                image_url: {
                  url: dataUrl,
                },
              },
              {
                type: "text",
                text: `Analyze the clothing item in the image.

                      Return only valid minified JSON. Do not include explanations.

                      Use this exact schema:
                      {"main_colors":[],"secondary_colors":[],"occasion":"","category":""}

                      Rules:
                      - main_colors must contain 1 or 2 colors only.
                      - secondary_colors must contain 0 to 4 colors only.
                      - Each color must be one word only.
                      - occasion must be exactly one of: Casual, Business, Formal.
                      - category must be exactly one of: Tops, Pants, Outerwear, Shoes, Dresses, Accessories.
                      - If uncertain, choose the closest valid option.
                      - Never return null.
                      - Never return extra fields.`,
              },
            ],
          },
        ],
      }),
    });

    const rekaResponse = await response.json();

    const payload = rekaResponse.choices[0].message.content;

    console.log("Reka response:", payload);

    return Response.json({ message: payload }, { status: 200 });
  }),
};
