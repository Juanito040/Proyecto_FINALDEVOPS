    import { ComputerService, DeviceService, MedicalDeviceService, DeviceHistoryService } from "@/core/service";
    import { Controller } from "./controller.elysia";
    import openapi from "@elysiajs/openapi";
    import Elysia from "elysia";
    import { cors } from "@elysiajs/cors";
    import { getLogger } from "@/core/utils/logger";

    export class ElysiaApiAdapter {
        private controller: Controller;
        public app: Elysia;

        constructor(
            computerService: ComputerService,
            deviceService: DeviceService,
            medicalDeviceService: MedicalDeviceService,
            deviceHistoryService: DeviceHistoryService
        ) {
            this.controller = new Controller(
                computerService,
                deviceService,
                medicalDeviceService,
                deviceHistoryService
            );

            this.app = new Elysia()
                .use(cors({
                    origin: [
                        "https://device-frontend-app.azurewebsites.net", // ⭐ Frontend en Azure
                        "http://localhost:5173" // ⭐ Para desarrollo local
                    ],
                    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
                    credentials: true,
                    allowedHeaders: ["*"]
                }))
                .use(openapi({}))
                // Middleware de logging para todas las peticiones
                .onRequest(({ request }) => {
                    const startTime = Date.now();
                    (request as any).__startTime = startTime;
                })
                .onResponse(({ request, set }) => {
                    const startTime = (request as any).__startTime || Date.now();
                    const duration = Date.now() - startTime;
                    const url = new URL(request.url);

                    const logger = getLogger();
                    logger.info('HTTP Request', {
                        method: request.method,
                        path: url.pathname,
                        status: set.status || 200,
                        duration: `${duration}ms`,
                        userAgent: request.headers.get('user-agent') || 'unknown',
                        origin: request.headers.get('origin') || 'unknown'
                    });
                })
                .onError(({ request, error, code }) => {
                    const startTime = (request as any).__startTime || Date.now();
                    const duration = Date.now() - startTime;
                    const url = new URL(request.url);

                    const logger = getLogger();
                    logger.error('HTTP Error', error instanceof Error ? error : undefined, {
                        method: request.method,
                        path: url.pathname,
                        errorCode: code,
                        duration: `${duration}ms`,
                        errorMessage: error?.toString()
                    });
                })
                .get("/", () => "Servidor funcionando correctamente 🚀")
                .use(this.controller.routes());
        }

        async run() {
            this.app.listen(3000);
            console.log("✅ El servidor está corriendo en el puerto 3000");
        }
    }
