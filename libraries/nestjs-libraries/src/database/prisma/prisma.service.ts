import { Injectable, OnModuleDestroy, OnModuleInit, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger('PrismaService');
  
  constructor() {
    super({
      log: [
        {
          emit: 'event',
          level: 'query',
        },
        {
          emit: 'event',
          level: 'error',
        },
      ],
      errorFormat: 'pretty',
    });
  }
  
  async onModuleInit() {
    try {
      this.logger.log('Attempting to connect to PostgreSQL database...');
      await this.$connect();
      this.logger.log('✅ Successfully connected to PostgreSQL database');
    } catch (error: any) {
      this.logger.error('❌ Failed to connect to PostgreSQL database:', error.message);
      this.logger.error('Check DATABASE_URL environment variable and ensure PostgreSQL is running');
      throw new Error(`Could not establish connection to database: ${error.message}`);
    }
  }

  async onModuleDestroy() {
    try {
      await this.$disconnect();
      this.logger.log('Database connection closed');
    } catch (error: any) {
      this.logger.error('Error disconnecting from database:', error.message);
    }
  }
}

@Injectable()
export class PrismaRepository<T extends keyof PrismaService> {
  public model: Pick<PrismaService, T>;
  constructor(private _prismaService: PrismaService) {
    this.model = this._prismaService;
  }
}

@Injectable()
export class PrismaTransaction {
  public model: Pick<PrismaService, '$transaction'>;
  constructor(private _prismaService: PrismaService) {
    this.model = this._prismaService;
  }
}
