# SummerBuild

## Starting supabase
```bash
npx supabase start
```

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