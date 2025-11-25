import { ComputerService, DeviceService, MedicalDeviceService, DeviceHistoryService, QRService } from "@/core/service";
import Elysia from "elysia";
import { CRITERIA_QUERY_PARAMS_SCHEMA, CriteriaHelper, CriteriaQueryParams } from "./criteria.helper";
import { COMPUTER_REQUEST_SCHEMA, ComputerRequest, MED_DEVICE_REQUEST_SCHEMA, MedDeviceRequest } from "@/core/dto";
import z from "zod";
import { Computer, EnteredDevice, FrequentComputer, MedicalDevice, DeviceHistoryEntry } from "@/core/domain";
import { auth, authMiddleware } from "@/core/auth";

export class Controller {
    constructor(
        private computerService: ComputerService,
        private deviceService: DeviceService,
        private medicalDeviceService: MedicalDeviceService,
        private deviceHistoryService: DeviceHistoryService
    ) {}

    public routes() {
    return (app: Elysia) =>
        app
            .group("/api", api =>
                api
                    .all("/auth/*", ({ request }) => auth.handler(request))

                    .use(authMiddleware)

                    .guard({ query: CRITERIA_QUERY_PARAMS_SCHEMA })

                    .post(
                        "/computers/checkin",
                        ({ body }) => this.checkinComputer(body),
                        {
                            type: "multipart/form-data",
                            body: COMPUTER_REQUEST_SCHEMA
                        }
                    )
                    .post(
                        "/medicaldevices/checkin",
                        ({ body }) => this.checkinMedicalDevice(body),
                        {
                            body: MED_DEVICE_REQUEST_SCHEMA
                        }
                    )
                    .post(
                        "/computers/frequent",
                        ({ body }) => this.registerFrequentComputer(body),
                        {
                            type: "multipart/form-data",
                            body: COMPUTER_REQUEST_SCHEMA
                        }
                    )
                    .get("/computers", ({ query }) => this.getComputers(query))
                    .get("/medicaldevices", ({ query }) => this.getMedicalDevices(query))
                    .get("/computers/frequent", ({ query }) => this.getFrequentComputers(query))
                    .get("/devices/entered", ({ query }) => this.getEnteredDevices(query))
                    .get("/devices/history", ({ query }) => this.getDeviceHistory(query))

                    .guard({
                        params: z.object({
                            id: z.string()
                        })
                    })
                    .patch(
                        "/computers/frequent/checkin/:id",
                        ({ params }) => this.checkinFrequentComputer(params.id)
                    )
                    .patch(
                        "/devices/checkout/:id",
                        ({ params }) => this.checkoutDevice(params.id)
                    )
                    .get(
                        "/computers/frequent/:id/qrcodes",
                        ({ params }) => this.getFrequentComputerQRCodes(params.id)
                    )
            )
}


    async checkinComputer(request: ComputerRequest): Promise<Computer> {
        return this.computerService.checkinComputer(request)
    }

    async checkinFrequentComputer(id: string): Promise<FrequentComputer> {
        return this.computerService.checkinFrequentComputer(id)
    }

    async checkinMedicalDevice(request: MedDeviceRequest): Promise<MedicalDevice> {
        return this.medicalDeviceService.checkinMedicalDevice(request)
    }

    async registerFrequentComputer(request: ComputerRequest): Promise<FrequentComputer> {
        return this.computerService.registerFrequentComputer(request)
    }

    async getComputers(queryParams: CriteriaQueryParams): Promise<Computer[]> {
        const criteria = CriteriaHelper.parseFromQuery(queryParams)

        return this.computerService.getComputers(criteria)
    }

    async getMedicalDevices(queryParams: CriteriaQueryParams): Promise<MedicalDevice[]> {
        const criteria = CriteriaHelper.parseFromQuery(queryParams)

        return this.medicalDeviceService.getMedicalDevices(criteria)
    }

    async getFrequentComputers(queryParams: CriteriaQueryParams): Promise<FrequentComputer[]> {
        const criteria = CriteriaHelper.parseFromQuery(queryParams)

        return this.computerService.getFrequentComputers(criteria)
    }

    async getEnteredDevices(queryParams: CriteriaQueryParams): Promise<EnteredDevice[]> {
        const criteria = CriteriaHelper.parseFromQuery(queryParams)

        return this.deviceService.getEnteredDevices(criteria)
    }

    async checkoutDevice(id: string): Promise<void> {
        return this.deviceService.checkoutDevice(id)
    }

    async getDeviceHistory(queryParams: CriteriaQueryParams): Promise<DeviceHistoryEntry[]> {
        // Por ahora devolvemos todo el historial sin filtros complejos
        return this.deviceHistoryService.getHistory()
    }

    async getFrequentComputerQRCodes(id: string): Promise<{ checkinQR: string; checkoutQR: string }> {
        // Obtener el dispositivo frecuente
        const frequentComputers = await this.computerService.getFrequentComputers({})
        const frequentComputer = frequentComputers.find(fc => fc.device.id === id)

        if (!frequentComputer) {
            throw new Error(`Dispositivo frecuente con ID ${id} no encontrado`)
        }

        // Generar códigos QR
        return await QRService.generateDeviceQRCodes(
            frequentComputer.checkinURL.href,
            frequentComputer.checkoutURL.href
        )
    }
}
