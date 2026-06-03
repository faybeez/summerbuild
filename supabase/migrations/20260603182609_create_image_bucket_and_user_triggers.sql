set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user_storage_folder()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE TRIGGER on_auth_user_created_storage AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_storage_folder();


  create policy "Give users access to own folder 14u3azc_1"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'clothes_photos'::text) AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])));



  create policy "Give users access to own folder 14u3azc_2"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'clothes_photos'::text) AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])));



  create policy "Give users access to own folder 14u3azc_3"
  on "storage"."objects"
  as permissive
  for update
  to authenticated
using (((bucket_id = 'clothes_photos'::text) AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])));



  create policy "Give users access to own folder 14u3azc_4"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using (((bucket_id = 'clothes_photos'::text) AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])));



