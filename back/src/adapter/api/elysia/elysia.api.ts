import { ComputerService, DeviceService, MedicalDeviceService, DeviceHistoryService } from "@/core/service";
import { Controller } from "./controller.elysia";
import openapi from "@elysiajs/openapi";
import Elysia from "elysia";
import { cors } from "@elysiajs/cors";

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
                allowedHeaders: ["Content-Type", "Authorization"]
            }))
            .use(openapi({}))
            .get("/", () => "Servidor funcionando correctamente 🚀")
            .use(this.controller.routes());
    }

    async run() {
        this.app.listen(3000);
        console.log("✅ El servidor está corriendo en el puerto 3000");
    }
}
