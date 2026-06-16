CREATE TABLE IF NOT EXISTS public.outfit_clothes (
    outfit_id bigint NOT NULL REFERENCES public.outfits(id) ON DELETE CASCADE,
    clothes_id bigint NOT NULL REFERENCES public.clothes(id) ON DELETE CASCADE,
    slot text,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    PRIMARY KEY (outfit_id, clothes_id),
    CONSTRAINT outfit_clothes_slot_check
        CHECK (slot IS NULL OR slot IN ('ACCESSORIES', 'OUTFIT'))
);

ALTER TABLE public.outfit_clothes OWNER TO postgres;

COMMENT ON TABLE public.outfit_clothes IS 'join table between outfits and clothes';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_outfit_clothes_clothes_id
  ON public.outfit_clothes(clothes_id);

CREATE INDEX IF NOT EXISTS idx_outfit_clothes_sort_order
  ON public.outfit_clothes(outfit_id, sort_order);

-- Policies
ALTER TABLE public.outfit_clothes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS outfit_clothes_crud_own_data ON public.outfit_clothes;

CREATE POLICY outfit_clothes_crud_own_data
ON public.outfit_clothes
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.outfits
        WHERE outfits.id = outfit_clothes.outfit_id
        AND outfits.user_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.outfits
        WHERE outfits.id = outfit_clothes.outfit_id
        AND outfits.user_id = auth.uid()
    )
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.outfit_clothes TO authenticated;