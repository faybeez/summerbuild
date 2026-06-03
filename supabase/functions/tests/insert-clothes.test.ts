import { assertEquals } from "@std/assert";
import { dirname, fromFileUrl, join } from "@std/path";
import { createClient, SupabaseClient } from "@supabase/supabase-js";

const TEST_DIR = dirname(fromFileUrl(import.meta.url));

function resolveFromTestDir(path: string): string {
  return join(TEST_DIR, path);
}

const rawImagePath = Deno.env.get("IMAGE_PATH");

if (!rawImagePath) {
  throw new Error("Missing IMAGE_PATH");
}

const imagePath = resolveFromTestDir(rawImagePath);
const imageBytes = await Deno.readFile(imagePath);
function requiredEnv(name: string): string {
  const value = Deno.env.get(name);

  if (!value) {
    throw new Error(`Missing environment variable: ${name}`);
  }

  return value;
}

const SUPABASE_URL = requiredEnv("SUPABASE_URL");
const SUPABASE_ANON_KEY = requiredEnv("SUPABASE_ANON_KEY");
const EMAIL = requiredEnv("EMAIL");
const PASSWORD = requiredEnv("PASSWORD");
const FUNCTION_NAME = requiredEnv("FUNCTION_NAME");
const IMAGE_PATH = requiredEnv("IMAGE_PATH");
const OPTIONS = {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
    detectSessionInUrl: false,
  },
}


function getFileName(path: string): string {
  return path.split(/[\\/]/).pop() ?? "photo.png";
}

Deno.test("create-clothes", async () => {
  var client: SupabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, OPTIONS);
  // const accessToken = await login();

  const imageBytes = await Deno.readFile(IMAGE_PATH);
  const fileName = getFileName(IMAGE_PATH);

  const formData = new FormData();
  formData.append("cost", "49.99");
  formData.append("times_worn", "0");
  formData.append("tag_ids", JSON.stringify([1, 3, 6]));

  formData.append(
    "image",
    new File([imageBytes], fileName, { type: "image/png" }),
  );

  const { data, error } = await client.auth.signInWithPassword({
    email: EMAIL,
    password: PASSWORD,
  });

      if (error) {
      console.error("Login error:", error);
      throw new Error("Failed to log in");
    }
    const accessToken = data.session?.access_token;
    if (!accessToken) {
      throw new Error("No access token received");
    }

    const {response} = await client.functions.invoke('insert-clothes', {
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${accessToken}`,
      },
      body: formData,
})
if (!response) {
  console.error("Function invocation error:");
  throw new Error("Failed to invoke function");
} else {

  assertEquals(
    response.status,
    200,
    `Expected 200 but got ${response.status}.`,
  );
}
});