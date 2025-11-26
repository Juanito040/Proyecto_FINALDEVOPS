import { ElysiaApiAdapter } from "./adapter/api/elysia";
import { FileSystemPhotoRepository } from "./adapter/photo/filesystem";
import { SQLiteDeviceRepository } from "./adapter/repository/sql"; // Importa el repo SQLite
import { ComputerService, DeviceService, MedicalDeviceService, DeviceHistoryService } from "./core/service";
import { initializeLogger } from "./core/utils/logger";

// Inicializar Logger con Application Insights y Axiom
const logger = initializeLogger({
  appInsightsConnectionString: process.env.APPLICATIONINSIGHTS_CONNECTION_STRING,
  axiomToken: process.env.AXIOM_TOKEN,
  axiomDataset: process.env.AXIOM_DATASET,
  environment: process.env.NODE_ENV || 'development',
});

logger.info('🚀 Application starting...', {
  environment: process.env.NODE_ENV || 'development',
  nodeEnv: process.env.NODE_ENV,
  timestamp: new Date().toISOString(),
});

// Inicializa el repositorio SQLite con la ruta a tu archivo .db
const deviceRepository = new SQLiteDeviceRepository("database.SQLite");
const photoRepository = new FileSystemPhotoRepository();

const computerService = new ComputerService(
    deviceRepository,
    photoRepository,
    new URL("http://localhost:3000/api")
);

const deviceService = new DeviceService(deviceRepository);

const medicalDeviceService = new MedicalDeviceService(
    deviceRepository,
    photoRepository
);

const deviceHistoryService = new DeviceHistoryService(deviceRepository);

const app = new ElysiaApiAdapter(
    computerService,
    deviceService,
    medicalDeviceService,
    deviceHistoryService
);

app.run();
