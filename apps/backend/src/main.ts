import { loadSwagger } from '@gitroom/helpers/swagger/load.swagger';

process.env.TZ = 'UTC';

import cookieParser from 'cookie-parser';
import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

import { initializeSentry } from '@gitroom/nestjs-libraries/sentry/initialize.sentry';
initializeSentry('backend', true);

import { SubscriptionExceptionFilter } from '@gitroom/backend/services/auth/permissions/subscription.exception';
import { HttpExceptionFilter } from '@gitroom/nestjs-libraries/services/exception.filter';
import { ConfigurationChecker } from '@gitroom/helpers/configuration/configuration.checker';

async function bootstrap() {
  const frontendUrl = process.env.FRONTEND_URL;
  const mainUrl = process.env.MAIN_URL;
  
  const allowedOrigins = [frontendUrl, mainUrl].filter(Boolean);
  
  if (!frontendUrl) {
    Logger.warn('CRITICAL: FRONTEND_URL not set. CORS will block requests. Set FRONTEND_URL in .env');
  }
  
  const app = await NestFactory.create(AppModule, {
    rawBody: true,
    cors: {
      credentials: true,
      exposedHeaders: [
        'reload',
        'onboarding',
        'activate',
        'auth',
        'showorg',
        'impersonate',
        'logout',
      ],
      origin: (origin: string, callback: (err: Error | null, allow?: boolean) => void) => {
        if (!origin) {
          return callback(null, true);
        }
        
        if (allowedOrigins.includes(origin)) {
          callback(null, true);
        } else {
          Logger.warn(`CORS blocked request from origin: ${origin}. Allowed origins: ${allowedOrigins.join(', ')}`);
          callback(new Error('CORS policy: origin not allowed'), false);
        }
      },
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'auth', 'showorg', 'impersonate'],
      maxAge: 3600,
    },
  });

  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
    })
  );

  app.use(cookieParser());
  app.useGlobalFilters(new SubscriptionExceptionFilter());
  app.useGlobalFilters(new HttpExceptionFilter());

  loadSwagger(app);

  const port = process.env.PORT || 3000;

  try {
    await app.listen(port);

    checkConfiguration(); // Do this last, so that users will see obvious issues at the end of the startup log without having to scroll up.

    Logger.log(`🚀 Backend is running on: http://localhost:${port}`);
  } catch (e) {
    Logger.error(`Backend failed to start on port ${port}`, e);
  }
}

function checkConfiguration() {
  const checker = new ConfigurationChecker();
  checker.readEnvFromProcess();
  checker.check();

  if (checker.hasIssues()) {
    for (const issue of checker.getIssues()) {
      Logger.warn(issue, 'Configuration issue');
    }

    Logger.warn('Configuration issues found: ' + checker.getIssuesCount());
  } else {
    Logger.log('Configuration check completed without any issues.');
  }
}

bootstrap();
