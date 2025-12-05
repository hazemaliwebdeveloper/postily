'use client';

import dynamic from 'next/dynamic';

export const PreviewDateClient = dynamic(
  () =>
    import('@gitroom/frontend/components/preview/render.preview.date').then(
      (mod) => mod.RenderPreviewDate
    ),
  { ssr: false, loading: () => <span>Loading...</span> }
);
