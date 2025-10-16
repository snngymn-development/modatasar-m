// basit emitter: server'ı boot etmeden swagger.json üretmek için (opsiyonel)
import { NestFactory } from '@nestjs/core'
import { AppModule } from './app.module.js'
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger'
import { writeFileSync } from 'node:fs'

const emit = async () => {
  const app = await NestFactory.create(AppModule, { logger: false })
  const config = new DocumentBuilder().setTitle('Deneme1 API').setVersion('1.0.0').build()
  const doc = SwaggerModule.createDocument(app, config)
  writeFileSync('openapi.json', JSON.stringify(doc, null, 2))
  await app.close()
}
emit()

