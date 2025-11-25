import React from 'react';
import './global.scss';
import './colors.scss';
import './polonto.css';

export const metadata = {
    title: 'pozmixal - Social Media Management',
    description: 'Manage your social media content across multiple platforms',
    icons: {
        icon: '/favicon.ico',
    },
};

export default function RootLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <html lang="en">
            <head />
            <body>{children}</body>
        </html>
    );
}