'use client';

import { useState, useCallback } from 'react';
import { useUser } from '../layout/user.context';
import { Button } from '@gitroom/react/form/button';
import copy from 'copy-to-clipboard';
import { useToaster } from '@gitroom/react/toaster/toaster';
import { useVariables } from '@gitroom/react/helpers/variable.context';
import { useT } from '@gitroom/react/translation/get.transation.service.client';

export const PublicComponent = () => {
  const user = useUser();
  const { backendUrl } = useVariables();
  const toaster = useToaster();
  const [reveal, setReveal] = useState(false);
  const [reveal2, setReveal2] = useState(false);
  
  const copyToClipboard = useCallback(() => {
    if (user?.publicApi) {
      toaster.show('API Key copied to clipboard', 'success');
      copy(user.publicApi);
    }
  }, [user?.publicApi, toaster]);
  
  const copyToClipboard2 = useCallback(() => {
    if (user?.publicApi && backendUrl) {
      toaster.show('MCP copied to clipboard', 'success');
      copy(`${backendUrl}/mcp/${user.publicApi}/sse`);
    }
  }, [user?.publicApi, backendUrl, toaster]);

  const t = useT();

  // Early return with null check
  if (!user?.publicApi) {
    return null;
  }

  // Memoize the MCP URL for consistency
  const mcpUrl = `${backendUrl}/mcp/${user.publicApi}/sse`;

  return (
    <div className="flex flex-col">
      <h3 className="text-[20px]">{t('public_api', 'Public API')}</h3>
      <div className="text-customColor18 mt-[4px]">
        {t(
          'use_pozmixal_api_to_integrate_with_your_tools',
          'Use Pozmixal API to integrate with your tools.'
        )}
        <br />
        <a
          className="underline hover:font-bold hover:underline"
          href="https://docs.pozmixal.com/public-api"
          target="_blank"
          rel="noopener noreferrer"
        >
          {t(
            'read_how_to_use_it_over_the_documentation',
            'Read how to use it over the documentation.'
          )}
        </a>
        <a
          className="underline hover:font-bold hover:underline"
          href="https://www.npmjs.com/package/n8n-nodes-pozmixal"
          target="_blank"
          rel="noopener noreferrer"
        >
          <br />
          {t(
            'check_n8n',
            'Check out our N8N custom node for Pozmixal.'
          )}
        </a>
      </div>
      <div className="my-[16px] mt-[16px] bg-sixth border-fifth items-center border rounded-[4px] p-[24px] flex gap-[24px]">
        <div className="flex items-center">
          {reveal ? (
            <span className="font-mono break-all">{user.publicApi}</span>
          ) : (
            <>
              <div className="blur-sm font-mono">{user.publicApi.slice(0, -5)}</div>
              <div className="font-mono">{user.publicApi.slice(-5)}</div>
            </>
          )}
        </div>
        <div>
          {!reveal ? (
            <Button onClick={() => setReveal(true)}>
              {t('reveal', 'Reveal')}
            </Button>
          ) : (
            <Button onClick={copyToClipboard}>
              {t('copy_key', 'Copy Key')}
            </Button>
          )}
        </div>
      </div>

      <h3 className="text-[20px]">{t('mcp', 'MCP')}</h3>
      <div className="text-customColor18 mt-[4px]">
        {t(
          'connect_your_mcp_client_to_pozmixal_to_schedule_your_posts_faster',
          'Connect your MCP client to Pozmixal to schedule your posts faster!'
        )}
      </div>
      <div className="my-[16px] mt-[16px] bg-sixth border-fifth items-center border rounded-[4px] p-[24px] flex gap-[24px]">
        <div className="flex items-center">
          {reveal2 ? (
            <span className="font-mono break-all">{mcpUrl}</span>
          ) : (
            <>
              <div className="blur-sm font-mono">
                {mcpUrl.slice(0, -5)}
              </div>
              <div className="font-mono">
                {mcpUrl.slice(-5)}
              </div>
            </>
          )}
        </div>
        <div>
          {!reveal2 ? (
            <Button onClick={() => setReveal2(true)}>
              {t('reveal', 'Reveal')}
            </Button>
          ) : (
            <Button onClick={copyToClipboard2}>
              {t('copy_key', 'Copy Key')}
            </Button>
          )}
        </div>
      </div>
    </div>
  );
};