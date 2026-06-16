CREATE TABLE IF NOT EXISTS public.outfits_tags (
    outfit_id bigint NOT NULL REFERENCES public.outfits(id) ON DELETE CASCADE,
    tag_id bigint NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
    PRIMARY KEY (outfit_id, tag_id)
);

ALTER TABLE public.outfits_tags OWNER TO postgres;

COMMENT ON TABLE public.outfits_tags IS 'join table between outfits and tags';

-- Index
CREATE INDEX IF NOT EXISTS idx_outfits_tags_outfit_id
  ON public.outfits_tags(outfit_id);

-- Policies
ALTER TABLE public.outfits_tags ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS outfits_tags_crud_own_data ON public.outfits_tags;

CREATE POLICY outfits_tags_crud_own_data
ON public.outfits_tags
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.outfits
        WHERE outfits.id = outfits_tags.outfit_id
        AND outfits.user_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.outfits
        WHERE outfits.id = outfits_tags.outfit_id
        AND outfits.user_id = auth.uid()
    )
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.outfits_tags TO authenticated;