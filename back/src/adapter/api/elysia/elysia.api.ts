    import { ComputerService, DeviceService, MedicalDeviceService, DeviceHistoryService } from "@/core/service";
    import { Controller } from "./controller.elysia";
    import openapi from "@elysiajs/openapi";
    import Elysia from "elysia";
    import { cors } from "@elysiajs/cors";
    import { getLogger } from "@/core/utils/logger";

    // Plugin de logging para Axiom
    const loggingPlugin = new Elysia()
        .derive(({ request }) => {
            return {
                startTime: Date.now()
            };
        })
        .onAfterHandle(({ request, set, startTime }) => {
            const duration = Date.now() - (startTime || Date.now());
            const url = new URL(request.url);

            try {
                const logger = getLogger();
                logger.info(`${request.method} ${url.pathname}`, {
                    method: request.method,
                    path: url.pathname,
                    url: url.pathname,
                    statusCode: set.status || 200,
                    executionTime: `${duration}ms`,
                    userAgent: request.headers.get('user-agent') || 'unknown',
                    ip: request.headers.get('x-forwarded-for') || request.headers.get('x-real-ip') || 'unknown',
                    origin: request.headers.get('origin') || 'direct',
                    service: 'device-management-api'
                });
            } catch (error) {
                console.error('Logging error:', error);
            }
        });

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
                .use(loggingPlugin)
                .get("/", () => "Servidor funcionando correctamente 🚀")
                .use(this.controller.routes());
        }

        async run() {
            this.app.listen(3000);
            console.log("✅ El servidor está corriendo en el puerto 3000");
        }
    }
