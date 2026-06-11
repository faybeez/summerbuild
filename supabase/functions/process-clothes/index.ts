import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";
import type { Database } from "../database.types.ts";

const REKA_API_KEY = Deno.env.get("REKA_API_KEY")!;
console.log("REKA_API_KEY:", REKA_API_KEY);

export default {
  fetch: withSupabase<Database>({ auth: "user" }, async (req, ctx) => {
    const { userClaims, supabase } = ctx;

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

    const allTags = await supabase
      .from("tags")
      .select("*")
      .or(`created_by.eq.${userClaims.id},created_by.is.null`);

    const colors =
      allTags
        .data!.filter((tag) => tag.tag_type.toUpperCase() === "COLORS")
        .map((tag) => tag.tag_name) || [];
    const occasion =
      allTags
        .data!.filter((tag) => tag.tag_type.toUpperCase() === "OCCASION")
        .map((tag) => tag.tag_name) || [];
    const weather =
      allTags
        .data!.filter((tag) => tag.tag_type.toUpperCase() === "WEATHER FIT")
        .map((tag) => tag.tag_name) || [];
    const categories =
      allTags
        .data!.filter((tag) => tag.tag_type.toUpperCase() === "CLOTHES TYPE")
        .map((tag) => tag.tag_name) || [];

    const prompt = `Analyze the clothing item in the image.
                      Do not include markdown, explanations, comments, duplicate keys, or extra fields.
                      Use this exact schema:
                      {"main_colors":[],"secondary_colors":[],"occasion":[],"weather":[],"category":""}

                      Field rules:

                      * main_colors must be an array with 1-2 strings.
                      * secondary_colors must be an array with 0-4 strings.
                      * occasion must be an array with 1-2 strings.
                      * weather must be an array with 1-2 strings.
                      * category must be a single string, not an array.

                      Allowed values:

                      * main_colors and secondary_colors must only use values from this list: ${colors.join(", ")}
                      * occasion must only use values from this list: ${occasion.join(", ")}
                      * weather must only use values from this list: ${weather.join(", ")}
                      * category must only use one value from this list: ${categories.join(", ")}

                      Classification rules:

                      * Choose the dominant visible clothing colors for main_colors.
                      * Use secondary_colors only for visible accent, pattern, logo, trim, or small-area colors.
                      * Do not repeat the same color in both main_colors and secondary_colors.
                      * Choose occasion based on where the clothing would reasonably be worn.
                      * Choose weather based on the clothing material, coverage, thickness, and likely comfort.
                      * Choose exactly one category that best represents the main clothing item.
                      * If multiple clothing items are visible, classify the most prominent item.
                      * If uncertain, choose the closest valid allowed value.
                      * Never return null.
                      * Never return undefined.
                      * Never return values outside the allowed lists.
                      * Always return all fields.

                      Output example:
                      {"main_colors":["Black"],"secondary_colors":["White"],"occasion":["Casual"],"weather":["Cold Weather"],"category":"Tops"}`;

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
                text: prompt,
              },
            ],
          },
        ],
      }),
    });

    const rekaResponse = await response.json();

    const payload = JSON.parse(rekaResponse.choices[0].message.content);

    console.log("Reka response:", payload);
    console.log("Reka response type:", typeof payload);

    return Response.json({ message: payload }, { status: 200 });
  }),
};
