import { type Express } from "express";
import Router from "../Router.js";
import { FILTER } from "$src/api.js";
import getRequest from "$src/request/get.js";

const API_BASE = process.env.API_URI ?? "http://localhost:16000/contratos";

async function getContratos(filter?: Record<string, string>): Promise<Record<string, unknown>[] | undefined> {
    try {
        const request_url = filter ? FILTER(API_BASE, filter) : API_BASE;
        const data = await getRequest(request_url);

        return <Record<string, unknown>[]>data;
    } catch(e) {
        console.error(e);
        return undefined;
    }
}

class ContratosRouter extends Router {
    constructor() {
        super("/contratos");
    }

    public async init(_app: Express): Promise<void> {
        console.log("  - Initializing api 'contratos' router...");

        this.router.get("/", async (_req, res) => {
            const contracts = await getContratos();

            res.render("contratos", { lcontracts: contracts });
        });
    }
}

export default ContratosRouter;