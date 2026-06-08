# SummerBuild

## Starting the application

1. change directories.

```bash
cd app
```

2. open an emulator.

3. change the `supabase_config.dart` file to use your own publishable key & url.

For more information, check the section on starting supabase.

4. run the app.

```bash
flutter run
```

## Starting supabase

Open the docker app.

```bash
npx supabase start
```
### Edge Functions

#### POST /functions/v1/insert-clothes
Creates a new clothing item for an authenticated user.

#### Authentication
The request must include:

```http
Authorization: Bearer <SUPABASE_ACCESS_TOKEN>
```

#### Request Format

The endpoint expects a `multipart/form-data` request with the fields:
```text
cost: number
times_worn: number
tag_ids: JSON string array of numbers
image: File
```

Example `tag_ids` value:

```json
[1, 2, 3]
```

Do not manually set the `Content-Type` header when using `FormData`. The browser or runtime will set the correct multipart boundary automatically.

#### Backend Flow

The function performs the following steps:

1. Verifies that the request comes from an authenticated user.
2. Reads the request as `multipart/form-data`.
3. Extracts the clothing metadata, tag IDs, and image file.
4. Validates that the uploaded file is an image.
5. Inserts the clothing metadata into the `clothes` table.
6. Uploads the image into the `clothes` Supabase Storage bucket.
7. Inserts related tag records into the clothes-tags relationship table if tag IDs are provided.
8. Returns the created clothing item and image path.

#### Storage Path Format

Uploaded images are stored using the authenticated user ID as the first folder level.

```text
{user_id}/{clothes_id}
```

This structure makes it easier to enforce Row Level Security policies so users can only access their own uploaded images.

#### Possible Errors

| Status Code | Meaning                                     |
| ----------- | ------------------------------------------- |
| `400`       | Missing or invalid request data             |
| `401`       | User is not authenticated                   |
| `413`       | Uploaded image is too large                 |
| `415`       | Uploaded file type is not supported         |
| `500`       | Storage upload or database insertion failed |

#### Notes

The endpoint should not accept a raw `File` inside a JSON body. Images must be sent using `multipart/form-data`.

The RLS policy for Supabase Storage should ensure that users can only upload, view, update, and delete files under their own user ID folder.

The `clothes` table insert should use the authenticated user ID from the Supabase auth context, not a user ID sent from the frontend.


### Testing Edge Functions
```bash
cd supabase/functions/tests
```

To test:
```bash
deno task test:[ENDPOINT NAME]
```

e.g.
```bash
deno task test:insert-clothes
```

To watch the edge function:
```bash
npx supabase functions serve
```

### Updating Migrations
```bash
supabase db diff -f name_of_migration
```

Note:
migrations are arranged in file alphabetical order (top - bottom)

# wardrobe_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.