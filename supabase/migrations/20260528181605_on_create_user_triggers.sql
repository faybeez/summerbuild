CREATE OR REPLACE FUNCTION public.handle_new_user_storage_folder()
RETURNS trigger AS $$
BEGIN
  INSERT INTO storage.objects (bucket_id, name, owner, metadata)
  VALUES (
    'clothes_photos',
    NEW.id || '/.keep',
    NEW.id,
    '{"mimetype": "text/plain"}'::jsonb
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Create the trigger on the auth.users table
CREATE TRIGGER on_auth_user_created_storage
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_storage_folder();
