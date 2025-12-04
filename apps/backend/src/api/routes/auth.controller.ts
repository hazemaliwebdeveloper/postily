import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  Req,
  Res,
} from '@nestjs/common';
import { Response, Request } from 'express';

import { CreateOrgUserDto } from '@gitroom/nestjs-libraries/dtos/auth/create.org.user.dto';
import { LoginUserDto } from '@gitroom/nestjs-libraries/dtos/auth/login.user.dto';
import { AuthService } from '@gitroom/backend/services/auth/auth.service';
import { ForgotReturnPasswordDto } from '@gitroom/nestjs-libraries/dtos/auth/forgot-return.password.dto';
import { ForgotPasswordDto } from '@gitroom/nestjs-libraries/dtos/auth/forgot.password.dto';
import { ApiTags } from '@nestjs/swagger';
import { getCookieUrlFromDomain } from '@gitroom/helpers/subdomain/subdomain.management';
import { EmailService } from '@gitroom/nestjs-libraries/services/email.service';
import { RealIP } from 'nestjs-real-ip';
import { UserAgent } from '@gitroom/nestjs-libraries/user/user.agent';
import { Provider } from '@prisma/client';

@ApiTags('Auth')
@Controller('/auth')
export class AuthController {
  constructor(
    private _authService: AuthService,
    private _emailService: EmailService
  ) {}

  @Get('/can-register')
  async canRegister() {
    return {
      register: await this._authService.canRegister(Provider.LOCAL as string),
    };
  }

  @Post('/register')
  async register(
    @Req() req: Request,
    @Body() body: CreateOrgUserDto,
    @Res({ passthrough: false }) response: Response,
    @RealIP() ip: string,
    @UserAgent() userAgent: string
  ) {
    try {
      const getOrgFromCookie = this._authService.getOrgFromCookie(
        req?.cookies?.org
      );

      const { jwt, addedOrg } = await this._authService.routeAuth(
        body.provider,
        body,
        ip,
        userAgent,
        getOrgFromCookie
      );

      const activationRequired =
        body.provider === 'LOCAL' && this._emailService.hasProvider();

      if (activationRequired) {
        response.header('activate', 'true');
        response.status(200).json({ activate: true });
        return;
      }

      const domain = getCookieUrlFromDomain(process.env.FRONTEND_URL!);
      const isLocalhost = domain === 'localhost';
      
      response.cookie('auth', jwt, {
        ...(isLocalhost ? { path: '/' } : { path: '/', domain }),
        ...(!process.env.NOT_SECURED
          ? {
              secure: true,
              httpOnly: true,
              sameSite: 'none',
            }
          : {
              httpOnly: false,
              sameSite: 'lax',
            }),
        expires: new Date(Date.now() + 1000 * 60 * 60 * 24 * 365),
      });

      response.header('auth', jwt);

      if (typeof addedOrg !== 'boolean' && addedOrg?.organizationId) {
        response.cookie('showorg', addedOrg.organizationId, {
          ...(isLocalhost ? { path: '/' } : { path: '/', domain }),
          ...(!process.env.NOT_SECURED
            ? {
                secure: true,
                httpOnly: true,
                sameSite: 'none',
              }
            : {
                httpOnly: false,
                sameSite: 'lax',
              }),
          expires: new Date(Date.now() + 1000 * 60 * 60 * 24 * 365),
        });

        response.header('showorg', addedOrg.organizationId);
      }

      response.header('onboarding', 'true');
      response.status(200).json({
        register: true,
        message: 'Registration successful',
        token: jwt,
      });
    } catch (e: any) {
      if (e.message.includes('Email already exists')) {
        return response.status(400).json({
          message: 'Email already registered',
          code: 'EMAIL_EXISTS',
          errors: { email: 'This email is already registered' }
        });
      }
      
      if (e.message.includes('Registration is disabled')) {
        return response.status(400).json({
          message: 'Registration is currently disabled',
          code: 'REGISTRATION_DISABLED'
        });
      }
      
      return response.status(400).json({
        message: e.message || 'Registration failed',
        code: 'REGISTRATION_FAILED'
      });
    }
  }

  @Post('/login')
  async login(
    @Req() req: Request,
    @Body() body: LoginUserDto,
    @Res({ passthrough: false }) response: Response,
    @RealIP() ip: string,
    @UserAgent() userAgent: string
  ) {
    try {
      const getOrgFromCookie = this._authService.getOrgFromCookie(
        req?.cookies?.org
      );

      const { jwt, addedOrg } = await this._authService.routeAuth(
        body.provider,
        body,
        ip,
        userAgent,
        getOrgFromCookie
      );

      const domain = getCookieUrlFromDomain(process.env.FRONTEND_URL!);
      const isLocalhost = domain === 'localhost';
      
      response.cookie('auth', jwt, {
        ...(isLocalhost ? { path: '/' } : { path: '/', domain }),
        ...(!process.env.NOT_SECURED
          ? {
              secure: true,
              httpOnly: true,
              sameSite: 'none',
            }
          : {
              httpOnly: false,
              sameSite: 'lax',
            }),
        expires: new Date(Date.now() + 1000 * 60 * 60 * 24 * 365),
      });

      response.header('auth', jwt);

      if (typeof addedOrg !== 'boolean' && addedOrg?.organizationId) {
        response.cookie('showorg', addedOrg.organizationId, {
          ...(isLocalhost ? { path: '/' } : { path: '/', domain }),
          ...(!process.env.NOT_SECURED
            ? {
                secure: true,
                httpOnly: true,
                sameSite: 'none',
              }
            : {
                httpOnly: false,
                sameSite: 'lax',
              }),
          expires: new Date(Date.now() + 1000 * 60 * 60 * 24 * 365),
        });

        response.header('showorg', addedOrg.organizationId);
      }

      response.header('reload', 'true');
      response.status(200).json({
        login: true,
        message: 'Login successful',
        token: jwt,
      });
    } catch (e: any) {
      if (e.message.includes('Invalid user name or password')) {
        return response.status(401).json({
          message: 'Invalid email or password',
          code: 'INVALID_CREDENTIALS',
          errors: { password: 'Incorrect password' }
        });
      }
      
      if (e.message.includes('User is not activated')) {
        return response.status(401).json({
          message: 'User account is not activated',
          code: 'USER_NOT_ACTIVATED'
        });
      }
      
      if (e.message.includes('Email already exists')) {
        return response.status(400).json({
          message: 'Email already registered',
          code: 'EMAIL_EXISTS',
          errors: { email: 'This email is already registered' }
        });
      }
      
      return response.status(400).json({
        message: e.message || 'Authentication failed',
        code: 'AUTH_FAILED'
      });
    }
  }

  @Post('/forgot')
  async forgot(@Body() body: ForgotPasswordDto) {
    try {
      await this._authService.forgot(body.email);
      return {
        forgot: true,
      };
    } catch (e) {
      return {
        forgot: false,
      };
    }
  }

  @Post('/forgot-return')
  async forgotReturn(@Body() body: ForgotReturnPasswordDto) {
    const reset = await this._authService.forgotReturn(body);
    return {
      reset: !!reset,
    };
  }

  @Get('/oauth/:provider')
  async oauthLink(@Param('provider') provider: string, @Query() query: any) {
    return this._authService.oauthLink(provider, query);
  }

  @Post('/activate')
  async activate(
    @Body('code') code: string,
    @Res({ passthrough: false }) response: Response
  ) {
    const activate = await this._authService.activate(code);
    if (!activate) {
      return response.status(200).json({ can: false });
    }

    const domain = getCookieUrlFromDomain(process.env.FRONTEND_URL!);
    const isLocalhost = domain === 'localhost';
    
    response.cookie('auth', activate, {
      ...(isLocalhost ? { path: '/' } : { path: '/', domain }),
      ...(!process.env.NOT_SECURED
        ? {
            secure: true,
            httpOnly: true,
            sameSite: 'none',
          }
        : {
            httpOnly: false,
            sameSite: 'lax',
          }),
      expires: new Date(Date.now() + 1000 * 60 * 60 * 24 * 365),
    });

    response.header('auth', activate);
    response.header('onboarding', 'true');

    return response.status(200).json({ can: true, token: activate });
  }

  @Post('/oauth/:provider/exists')
  async oauthExists(
    @Body('code') code: string,
    @Param('provider') provider: string,
    @Res({ passthrough: false }) response: Response
  ) {
    const { jwt, token } = await this._authService.checkExists(provider, code);

    if (token) {
      return response.json({ token });
    }

    const domain = getCookieUrlFromDomain(process.env.FRONTEND_URL!);
    const isLocalhost = domain === 'localhost';
    
    response.cookie('auth', jwt, {
      ...(isLocalhost ? { path: '/' } : { path: '/', domain }),
      ...(!process.env.NOT_SECURED
        ? {
            secure: true,
            httpOnly: true,
            sameSite: 'none',
          }
        : {
            httpOnly: false,
            sameSite: 'lax',
          }),
      expires: new Date(Date.now() + 1000 * 60 * 60 * 24 * 365),
    });

    response.header('auth', jwt);
    response.header('reload', 'true');

    response.status(200).json({
      login: true,
      token: jwt,
      user: {
        id: jwt
      }
    });
  }
}
