import 'reflect-metadata'
import { NestFactory } from '@nestjs/core'
import { AppModule } from './app.module'
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger'
import { ValidationPipe } from '@nestjs/common'

async function bootstrap(){
  const app = await NestFactory.create(AppModule)
  
  // Enable CORS for all origins (configure for production)
  app.enableCors({
    origin: true, // Allow all origins
    credentials: true, // Enable credentials to match frontend
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
  
  // Global validation pipe with class-validator
  app.useGlobalPipes(new ValidationPipe({ 
    whitelist: true,      // Strip properties that don't have decorators
    transform: true       // Transform payloads to DTO instances
  }))

  const config = new DocumentBuilder()
    .setTitle('Deneme1 API')
    .setDescription('OpenAPI spec for clients (RN/Flutter/.NET)')
    .setVersion('1.0.0')
    .build()
  const document = SwaggerModule.createDocument(app, config)
  SwaggerModule.setup('docs', app, document)

  await app.listen(process.env.PORT || 3000)
}
bootstrap()