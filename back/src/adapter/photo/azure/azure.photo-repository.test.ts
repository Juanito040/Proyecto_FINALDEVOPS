// IMPORTANTE: Cargar variables de entorno ANTES de cualquier importación
import { parse } from "dotenv";
import { readFileSync, existsSync } from "fs";
import { join, resolve } from "path";

// Cargar .env manualmente - buscar desde la raíz del proyecto
try {
  // __dirname apunta a: pds006-frameworks-20252/src/adapter/photo/azure
  // Necesitamos subir 4 niveles para llegar a la raíz
  const projectRoot = resolve(__dirname, "..", "..", "..", "..");
  const envPath = join(projectRoot, ".env");
  
  if (!existsSync(envPath)) {
    throw new Error(`No se encontró .env en: ${envPath}`);
  }

  const envContent = readFileSync(envPath, "utf-8");
  const envVars = parse(envContent);
  
  // Asignar las variables a process.env
  Object.entries(envVars).forEach(([key, value]) => {
    if (value) {
      process.env[key] = value;
    }
  });
  
  console.log("✅ Variables de entorno cargadas desde:", envPath);
} catch (error) {
  console.error("⚠️  Error cargando .env:", error);
  console.error("Ubicación actual:", __dirname);
}

import { DevicePhotoRepository } from "@/core/repository"
import { AzurePhotoRepository } from "./azure.photo-repository"
import { beforeAll, describe, expect, it } from "bun:test"
import { DeviceId } from "@/core/domain"

async function createTestImageFile(): Promise<File> {
  const pngBytes = new Uint8Array([
    0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, // PNG header
    0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52, // IHDR
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 pixel
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89,
    0x00, 0x00, 0x00, 0x0a, 0x49, 0x44, 0x41, 0x54, // IDAT
    0x78, 0x9c, 0x63, 0xf8, 0xcf, 0xc0, 0x00, 0x00, 0x03,
    0x01, 0x01, 0x00, 0x18, 0xdd, 0x8d, 0x18, 0x00, 0x00,
    0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82
  ])
  return new File([pngBytes], "test.png", { type: "image/png" })
}

describe("AzurePhotoRepository", () => {
  let repo: DevicePhotoRepository
  let imageFile: File
  let uploadedUrl: URL
  const testDeviceId: DeviceId = "test-device-" + Date.now()

  beforeAll(async () => {
    console.log("\n🔍 Verificando configuración de Azure...");
    console.log("AZURE_STORAGE_ACCOUNT:", process.env.AZURE_STORAGE_ACCOUNT || "❌ No configurado");
    console.log("AZURE_STORAGE_KEY:", process.env.AZURE_STORAGE_KEY ? "✅ Configurado" : "❌ No configurado");
    console.log("AZURE_CONTAINER_NAME:", process.env.AZURE_CONTAINER_NAME || "device-photos (default)");
    
    if (!process.env.AZURE_STORAGE_ACCOUNT || !process.env.AZURE_STORAGE_KEY) {
      console.error("\n❌ ERROR: Variables de entorno no configuradas!");
      console.error("Verifica que el archivo .env esté en la raíz del proyecto pds006-frameworks-20252");
      throw new Error("Variables de entorno requeridas no están configuradas");
    }

    repo = new AzurePhotoRepository()
    imageFile = await createTestImageFile()
  })

  it("should upload an image and return a valid URL", async () => {
    uploadedUrl = await repo.savePhoto(imageFile, testDeviceId)
    expect(uploadedUrl).toBeInstanceOf(URL)
    expect(uploadedUrl.href.length).toBeGreaterThan(0)
    expect(uploadedUrl.href).toContain("blob.core.windows.net")
    console.log("✅ Foto subida exitosamente:", uploadedUrl.href)
  })

  it("should return the same image data when fetched from the URL", async () => {
    const res = await fetch(uploadedUrl)
    expect(res.ok).toBe(true)
    const returnedBytes = new Uint8Array(await res.arrayBuffer())
    const originalBytes = new Uint8Array(await imageFile.arrayBuffer())
    expect(returnedBytes).toEqual(originalBytes)
    console.log("✅ Imagen verificada correctamente")
  })
})