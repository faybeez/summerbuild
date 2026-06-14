import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";
import type { Database } from "../database.types.ts";

const REKA_API_KEY = Deno.env.get("REKA_API_KEY")!;

interface ClothingTag {
  id: number;
  tagType: string;
  tagValue: string;
  tagDisplayName: string;
}

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

    const allTagsResult = await supabase
      .from("tags")
      .select("*")
      .or(`created_by.eq.${userClaims.id},created_by.is.null`);

    const allTags = allTagsResult.data ?? [];

    const findTag = (type: string, name: string) =>
      allTags.find(
        (t) =>
          t.tag_type.toUpperCase() === type.toUpperCase() &&
          (t.tag_value === name.toUpperCase() ||
            t.tag_display_name.toUpperCase() === name.toUpperCase()),
      );

    const colors =
      allTags
        .filter((t) => t.tag_type.toUpperCase() === "COLOR")
        .map((t) => t.tag_value) ?? [];
    const occasion =
      allTags
        .filter((t) => t.tag_type.toUpperCase() === "OCCASION")
        .map((t) => t.tag_value) ?? [];
    const weather =
      allTags
        .filter((t) => t.tag_type.toUpperCase() === "WEATHER")
        .map((t) => t.tag_value) ?? [];
    const categories =
      allTags
        .filter((t) => t.tag_type.toUpperCase() === "CATEGORY")
        .map((t) => t.tag_value) ?? [];

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
                      {"main_colors":["BLACK"],"secondary_colors":["WHITE"],"occasion":["CASUAL"],"weather":["COLD"],"category":"TOPS"}`;

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
                image_url: { url: dataUrl },
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

    const validatedMainColors: string[] = (payload.main_colors ?? []).filter(
      (name: string) => findTag("COLOR", name) !== undefined,
    );

    const validatedSecondaryColors: string[] = (
      payload.secondary_colors ?? []
    ).filter((name: string) => findTag("COLOR", name) !== undefined);

    const validatedOccasion: string[] = (payload.occasion ?? []).filter(
      (name: string) => findTag("OCCASION", name) !== undefined,
    );

    const validatedWeather: string[] = (payload.weather ?? []).filter(
      (name: string) => findTag("WEATHER", name) !== undefined,
    );

    const categoryTag =
      typeof payload.category === "string"
        ? findTag("CATEGORY", payload.category)
        : undefined;

    console.log("Validated payload:", {
      validatedMainColors,
      validatedSecondaryColors,
      validatedOccasion,
      validatedWeather,
      category: categoryTag?.tag_value ?? null,
    });

    const toClothingTag = (type: string, name: string): ClothingTag | null => {
      const tag = findTag(type, name);
      if (!tag) return null;
      return {
        id: tag.id,
        tagType: tag.tag_type,
        tagValue: tag.tag_value,
        tagDisplayName: tag.tag_display_name,
      };
    };

    const mainColors = validatedMainColors
      .map((n) => toClothingTag("COLOR", n))
      .filter((t): t is ClothingTag => t !== null);

    const secondaryColors = validatedSecondaryColors
      .map((n) => toClothingTag("COLOR", n))
      .filter((t): t is ClothingTag => t !== null);

    const occasionTags = validatedOccasion
      .map((n) => toClothingTag("OCCASION", n))
      .filter((t): t is ClothingTag => t !== null);

    const weatherTags = validatedWeather
      .map((n) => toClothingTag("WEATHER", n))
      .filter((t): t is ClothingTag => t !== null);

    const category = categoryTag
      ? toClothingTag("CATEGORY", categoryTag.tag_value)
      : null;

    return Response.json(
      {
        mainColors,
        secondaryColors,
        occasion: occasionTags,
        weather: weatherTags,
        category,
      },
      { status: 200 },
    );
  }),
};
