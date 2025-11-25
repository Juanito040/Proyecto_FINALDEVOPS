import * as appInsights from 'applicationinsights';
import { Axiom } from '@axiomhq/js';

export interface LoggerConfig {
  appInsightsConnectionString?: string;
  axiomToken?: string;
  axiomDataset?: string;
  environment: string;
}

export class Logger {
  private appInsightsClient?: appInsights.TelemetryClient;
  private axiomClient?: Axiom;
  private axiomDataset?: string;
  private environment: string;

  constructor(config: LoggerConfig) {
    this.environment = config.environment;

    // Configurar Application Insights
    if (config.appInsightsConnectionString) {
      appInsights.setup(config.appInsightsConnectionString)
        .setAutoDependencyCorrelation(true)
        .setAutoCollectRequests(true)
        .setAutoCollectPerformance(true, true)
        .setAutoCollectExceptions(true)
        .setAutoCollectDependencies(true)
        .setAutoCollectConsole(true)
        .setUseDiskRetryCaching(true)
        .start();

      this.appInsightsClient = appInsights.defaultClient;
      console.log('✅ Application Insights configured');
    }

    // Configurar Axiom
    if (config.axiomToken && config.axiomDataset) {
      this.axiomClient = new Axiom({
        token: config.axiomToken,
      });
      this.axiomDataset = config.axiomDataset;
      console.log('✅ Axiom configured');
    }
  }

  private async sendToAxiom(level: string, message: string, properties?: Record<string, any>) {
    if (this.axiomClient && this.axiomDataset) {
      try {
        await this.axiomClient.ingest(this.axiomDataset, [
          {
            timestamp: new Date().toISOString(),
            level,
            message,
            environment: this.environment,
            ...properties,
          },
        ]);
      } catch (error) {
        console.error('Error sending logs to Axiom:', error);
      }
    }
  }

  info(message: string, properties?: Record<string, any>) {
    console.log(`[INFO] ${message}`, properties);

    if (this.appInsightsClient) {
      this.appInsightsClient.trackTrace({
        message,
        severity: appInsights.Contracts.SeverityLevel.Information,
        properties,
      });
    }

    this.sendToAxiom('info', message, properties);
  }

  warn(message: string, properties?: Record<string, any>) {
    console.warn(`[WARN] ${message}`, properties);

    if (this.appInsightsClient) {
      this.appInsightsClient.trackTrace({
        message,
        severity: appInsights.Contracts.SeverityLevel.Warning,
        properties,
      });
    }

    this.sendToAxiom('warn', message, properties);
  }

  error(message: string, error?: Error, properties?: Record<string, any>) {
    console.error(`[ERROR] ${message}`, error, properties);

    if (this.appInsightsClient) {
      if (error) {
        this.appInsightsClient.trackException({
          exception: error,
          properties: { message, ...properties },
        });
      } else {
        this.appInsightsClient.trackTrace({
          message,
          severity: appInsights.Contracts.SeverityLevel.Error,
          properties,
        });
      }
    }

    this.sendToAxiom('error', message, {
      error: error?.message,
      stack: error?.stack,
      ...properties,
    });
  }

  event(name: string, properties?: Record<string, any>) {
    console.log(`[EVENT] ${name}`, properties);

    if (this.appInsightsClient) {
      this.appInsightsClient.trackEvent({
        name,
        properties,
      });
    }

    this.sendToAxiom('event', name, properties);
  }

  metric(name: string, value: number, properties?: Record<string, any>) {
    console.log(`[METRIC] ${name}: ${value}`, properties);

    if (this.appInsightsClient) {
      this.appInsightsClient.trackMetric({
        name,
        value,
        properties,
      });
    }

    this.sendToAxiom('metric', name, { value, ...properties });
  }

  async flush() {
    if (this.appInsightsClient) {
      this.appInsightsClient.flush();
    }
    if (this.axiomClient) {
      await this.axiomClient.flush();
    }
  }
}

// Singleton instance
let loggerInstance: Logger | null = null;

export function initializeLogger(config: LoggerConfig): Logger {
  loggerInstance = new Logger(config);
  return loggerInstance;
}

export function getLogger(): Logger {
  if (!loggerInstance) {
    throw new Error('Logger not initialized. Call initializeLogger first.');
  }
  return loggerInstance;
}
