'use client';

import { EventEmitter } from 'events';
import { useEffect, useState } from 'react';
import { useVariables } from '@gitroom/react/helpers/variable.context';
import { useT } from '@gitroom/react/translation/get.transation.service.client';

export const supportEmitter = new EventEmitter();

export const Support = () => {
  const [show, setShow] = useState(true);
  const { whatsappUrl } = useVariables(); // Changed from discordUrl to whatsappUrl
  const t = useT();

  useEffect(() => {
    supportEmitter.on('change', setShow);
    return () => {
      supportEmitter.off('state', setShow);
    };
  }, []);

  if (!whatsappUrl || !show) return null; // Updated variable reference

  return (
    <div
      className="bg-customColor39 w-[194px] h-[58px] fixed end-[20px] bottom-[20px] z-[500] text-[16px] text-customColor40 rounded-[30px] !rounded-br-[0] cursor-pointer flex justify-center items-center gap-[10px]"
      onClick={() => window.open(whatsappUrl)} // Updated variable reference
    >
      <div>
        {/* WhatsApp SVG Icon - Replaced Discord icon */}
        <svg
          width="32"
          height="33"
          viewBox="0 0 32 33"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="mb-[4px]"
        >
          <path
            d="M16.0001 0.5C7.1635 0.5 0 7.6635 0 16.5C0 19.5166 1.0235 22.2533 2.6685 24.4319L0.5 32.5L8.5681 30.3315C10.7467 31.9765 13.4834 33 16.5 33C25.3366 33 32.5 25.8366 32.5 16.5C32.5 7.1635 25.3366 0.5 16.0001 0.5ZM16.0001 29.8667C13.4834 29.8667 11.1128 29.021 9.2061 27.634L8.7001 27.2819L3.7666 28.5681L5.053 23.6346L4.651 23.0833C3.1855 21.1128 2.3333 18.8667 2.3333 16.5C2.3333 8.9535 8.4535 2.8333 16.0001 2.8333C23.5466 2.8333 29.6667 8.9535 29.6667 16.5C29.6667 24.0466 23.5466 30.1667 16.0001 30.1667V29.8667ZM23.3333 19.8333L20.8333 18.5C20.8333 18.5 19.5 17.8333 18.1666 17.1667C17.5 16.8333 16.8333 16.8333 16.5 17.1667C16.1666 17.5 15.8333 18.1667 15.8333 18.5C15.5 19.1667 14.8333 19.8333 14.1666 20.1667C13.5 20.5 12.8333 20.5 12.1666 20.1667C11.5 19.8333 10.8333 19.1667 10.1666 18.5C9.8333 18.1667 9.5 17.8333 9.1666 17.5C8.8333 17.1667 8.8333 16.8333 9.1666 16.5C9.5 16.1667 10.1666 15.8333 10.8333 15.5C11.5 15.1667 12.1666 14.8333 12.8333 14.5C13.5 14.1667 14.1666 14.1667 14.8333 14.5C15.1666 14.8333 15.8333 15.1667 16.5 15.8333C17.1666 16.5 17.8333 17.1667 18.1666 17.8333C18.8333 18.5 19.5 19.1667 20.1666 19.8333C20.8333 20.5 21.8333 21.1667 23.3333 19.8333Z"
            fill="currentColor"
          />
        </svg>
      </div>
      <div>{t('whatsapp_support', 'WhatsApp Support')}</div> {/* Updated text */}
    </div>
  );
};