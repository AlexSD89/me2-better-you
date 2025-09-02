import { z } from 'zod';

// 基础验证schemas
export const companySchema = z.object({
  name: z.string().min(1, 'Company name is required').max(255),
  slug: z.string().min(1, 'Slug is required').regex(/^[a-z0-9-]+$/, 'Invalid slug format'),
  description: z.string().optional(),
  website: z.string().url('Invalid URL format').optional().or(z.literal('')),
  foundedYear: z.number().int().min(1800).max(new Date().getFullYear()).optional(),
  teamSize: z.number().int().min(1).max(100000).optional(),
  teamSizeSource: z.string().optional(),
  industry: z.string().max(100).optional(),
  subIndustry: z.string().max(100).optional(),
  stage: z.enum(['seed', 'seriesA', 'seriesB', 'seriesC', 'growth', 'mature']).optional(),
  location: z.string().max(255).optional(),
  logoUrl: z.string().url().optional().or(z.literal('')),
  linkedinUrl: z.string().url().optional().or(z.literal('')),
  twitterUrl: z.string().url().optional().or(z.literal('')),
  githubUrl: z.string().url().optional().or(z.literal('')),
  crunchbaseUrl: z.string().url().optional().or(z.literal('')),
  isActive: z.boolean().default(true),
  isPublic: z.boolean().default(false),
  isUnicorn: z.boolean().default(false)
});

export const mrrDataSchema = z.object({
  companyId: z.string().cuid('Invalid company ID'),
  dataSourceId: z.string().cuid('Invalid data source ID'),
  monthYear: z.string().regex(/^\d{4}-\d{2}$/, 'Month year must be in YYYY-MM format'),
  quarter: z.string().regex(/^\d{4}-Q[1-4]$/, 'Quarter must be in YYYY-Q1 format'),
  year: z.number().int().min(2000).max(new Date().getFullYear()),
  month: z.number().int().min(1).max(12),
  mrrAmount: z.number().positive('MRR amount must be positive'),
  currency: z.string().length(3, 'Currency must be 3 characters').default('USD'),
  growthRate: z.number().min(-100).max(10000).optional(), // -100% to 10000% growth
  yoyGrowthRate: z.number().min(-100).max(10000).optional(),
  confidenceScore: z.number().min(0).max(1).default(0.5),
  dataQuality: z.enum(['high', 'medium', 'low']).default('medium'),
  isEstimated: z.boolean().default(false),
  estimationMethod: z.string().max(255).optional(),
  isVerified: z.boolean().default(false),
  verifiedBy: z.string().optional(),
  verifiedAt: z.date().optional()
});

export const investmentScoreSchema = z.object({
  companyId: z.string().cuid('Invalid company ID'),
  scalabilityScore: z.number().min(0).max(100).default(0),
  productMarketFitScore: z.number().min(0).max(100).default(0),
  executionScore: z.number().min(0).max(100).default(0),
  leadershipScore: z.number().min(0).max(100).default(0),
  opportunityScore: z.number().min(0).max(100).default(0),
  technologyScore: z.number().min(0).max(100).default(0),
  financialScore: z.number().min(0).max(100).default(0),
  marketScore: z.number().min(0).max(100).default(0),
  teamScore: z.number().min(0).max(100).default(0),
  riskScore: z.number().min(0).max(100).default(0),
  totalScore: z.number().min(0).max(1000).default(0),
  normalizedScore: z.number().min(0).max(100).default(0),
  recommendation: z.enum(['strong_buy', 'buy', 'hold', 'sell', 'strong_sell']),
  riskLevel: z.enum(['low', 'medium', 'high', 'very_high']),
  targetValuation: z.number().positive().optional(),
  recommendedInvestment: z.number().positive().optional(),
  expectedReturn: z.number().min(-100).max(10000).optional(), // -100% to 10000%
  timeHorizon: z.number().int().min(1).max(120).optional(), // 1-120 months
  analystId: z.string().optional(),
  analysisMethod: z.string().max(255).optional(),
  keyInsights: z.record(z.any()).optional(),
  riskFactors: z.record(z.any()).optional(),
  strengths: z.record(z.any()).optional(),
  weaknesses: z.record(z.any()).optional()
});

export const dataSourceSchema = z.object({
  name: z.string().min(1, 'Data source name is required').max(255),
  type: z.enum(['api', 'scraping', 'manual', 'file_upload']),
  description: z.string().max(1000).optional(),
  baseUrl: z.string().url('Invalid URL format').optional().or(z.literal('')),
  apiKey: z.string().optional(),
  isActive: z.boolean().default(true),
  rateLimit: z.number().int().positive().optional(),
  reliability: z.number().min(0).max(1).default(0.5)
});

export const collectionTaskSchema = z.object({
  companyId: z.string().cuid('Invalid company ID'),
  dataSourceId: z.string().cuid('Invalid data source ID'),
  taskType: z.enum(['mrr_collection', 'company_update', 'market_analysis']),
  priority: z.enum(['low', 'medium', 'high', 'urgent']).default('medium'),
  status: z.enum(['pending', 'running', 'completed', 'failed', 'cancelled']).default('pending'),
  scheduledAt: z.date().optional(),
  retryCount: z.number().int().min(0).default(0),
  maxRetries: z.number().int().min(0).max(10).default(3),
  parameters: z.record(z.any()).optional(),
  configuration: z.record(z.any()).optional()
});

export const fundingRoundSchema = z.object({
  companyId: z.string().cuid('Invalid company ID'),
  roundType: z.enum(['seed', 'seriesA', 'seriesB', 'seriesC', 'bridge', 'ipo']),
  amount: z.number().positive('Funding amount must be positive'),
  currency: z.string().length(3, 'Currency must be 3 characters').default('USD'),
  valuation: z.number().positive().optional(),
  valuationType: z.enum(['pre_money', 'post_money']).optional(),
  announcedDate: z.date(),
  closedDate: z.date().optional(),
  leadInvestors: z.array(z.string()).optional(),
  investors: z.array(z.string()).optional(),
  investorCount: z.number().int().min(0).optional(),
  source: z.string().max(255).optional(),
  sourceUrl: z.string().url().optional().or(z.literal('')),
  isVerified: z.boolean().default(false)
});

export const companyMetricsSchema = z.object({
  companyId: z.string().cuid('Invalid company ID'),
  date: z.date(),
  period: z.enum(['monthly', 'quarterly', 'annually']),
  totalUsers: z.number().int().min(0).optional(),
  activeUsers: z.number().int().min(0).optional(),
  paidUsers: z.number().int().min(0).optional(),
  churnRate: z.number().min(0).max(100).optional(), // 0-100%
  revenue: z.number().positive().optional(),
  arr: z.number().positive().optional(),
  grossMargin: z.number().min(0).max(100).optional(), // 0-100%
  burnRate: z.number().positive().optional(),
  runway: z.number().int().min(0).optional(), // months
  userGrowthRate: z.number().min(-100).max(10000).optional(),
  revenueGrowthRate: z.number().min(-100).max(10000).optional(),
  marketShare: z.number().min(0).max(100).optional(),
  customerAcquisitionCost: z.number().positive().optional(),
  lifetimeValue: z.number().positive().optional(),
  ltv2cacRatio: z.number().positive().optional(),
  dataSource: z.string().max(255).optional(),
  confidenceScore: z.number().min(0).max(1).default(0.5),
  isEstimated: z.boolean().default(false)
});

// 查询参数验证schemas
export const paginationSchema = z.object({
  page: z.number().int().min(1).default(1),
  limit: z.number().int().min(1).max(100).default(20),
  sortBy: z.string().optional(),
  sortOrder: z.enum(['asc', 'desc']).default('asc')
});

export const companyFiltersSchema = z.object({
  search: z.string().max(255).optional(),
  industry: z.array(z.string()).optional(),
  stage: z.array(z.string()).optional(),
  teamSizeMin: z.number().int().min(1).optional(),
  teamSizeMax: z.number().int().min(1).optional(),
  mrrMin: z.number().positive().optional(),
  mrrMax: z.number().positive().optional(),
  growthRateMin: z.number().optional(),
  growthRateMax: z.number().optional(),
  isActive: z.boolean().optional(),
  hasRecentData: z.boolean().optional()
});

export const mrrDataFiltersSchema = z.object({
  companyId: z.string().cuid().optional(),
  dateFrom: z.string().regex(/^\d{4}-\d{2}$/).optional(),
  dateTo: z.string().regex(/^\d{4}-\d{2}$/).optional(),
  confidenceMin: z.number().min(0).max(1).optional(),
  dataQuality: z.array(z.enum(['high', 'medium', 'low'])).optional(),
  isVerified: z.boolean().optional(),
  isEstimated: z.boolean().optional()
});

export const dateRangeSchema = z.object({
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Start date must be in YYYY-MM-DD format'),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'End date must be in YYYY-MM-DD format')
}).refine(
  (data) => new Date(data.startDate) <= new Date(data.endDate),
  {
    message: 'Start date must be before or equal to end date',
    path: ['endDate']
  }
);

// API请求验证schemas
export const createCompanyRequestSchema = companySchema;

export const updateCompanyRequestSchema = companySchema.partial();

export const createMrrDataRequestSchema = mrrDataSchema.omit({
  quarter: true,
  year: true,
  month: true
}).extend({
  // 自动从monthYear计算这些字段
});

export const updateMrrDataRequestSchema = createMrrDataRequestSchema.partial();

export const createInvestmentScoreRequestSchema = investmentScoreSchema.omit({
  totalScore: true,
  normalizedScore: true
}).extend({
  // 自动计算总分和标准化分数
});

export const updateInvestmentScoreRequestSchema = createInvestmentScoreRequestSchema.partial();

export const bulkCreateMrrDataRequestSchema = z.object({
  data: z.array(createMrrDataRequestSchema).min(1, 'At least one MRR data entry is required').max(1000, 'Too many entries in single request')
});

export const bulkCreateTasksRequestSchema = z.object({
  companyIds: z.array(z.string().cuid()).min(1, 'At least one company ID is required').max(100, 'Too many companies in single request'),
  dataSourceId: z.string().cuid('Invalid data source ID'),
  taskType: z.enum(['mrr_collection', 'company_update', 'market_analysis']),
  priority: z.enum(['low', 'medium', 'high', 'urgent']).default('medium'),
  parameters: z.record(z.any()).optional()
});

// 验证错误格式化
export interface ValidationError {
  field: string;
  message: string;
  code: string;
}

export function formatZodError(error: z.ZodError): ValidationError[] {
  return error.errors.map(err => ({
    field: err.path.join('.'),
    message: err.message,
    code: err.code
  }));
}

// 通用验证函数
export function validateData<T>(schema: z.ZodSchema<T>, data: unknown): T {
  try {
    return schema.parse(data);
  } catch (error) {
    if (error instanceof z.ZodError) {
      const formattedErrors = formatZodError(error);
      throw new Error(`Validation failed: ${JSON.stringify(formattedErrors)}`);
    }
    throw error;
  }
}

// 异步验证函数（用于数据库约束验证）
export async function validateDataAsync<T>(
  schema: z.ZodSchema<T>, 
  data: unknown,
  customValidators?: Array<(data: T) => Promise<void>>
): Promise<T> {
  const validatedData = validateData(schema, data);
  
  if (customValidators) {
    for (const validator of customValidators) {
      await validator(validatedData);
    }
  }
  
  return validatedData;
}

// 预定义的自定义验证器
export const customValidators = {
  // 验证公司名称唯一性
  async validateUniqueCompanyName(data: { name: string }) {
    // 这里需要注入repository依赖
    // const exists = await companyRepository.exists({ name: data.name });
    // if (exists) {
    //   throw new Error('Company name already exists');
    // }
  },

  // 验证公司slug唯一性
  async validateUniqueCompanySlug(data: { slug: string }) {
    // const exists = await companyRepository.exists({ slug: data.slug });
    // if (exists) {
    //   throw new Error('Company slug already exists');
    // }
  },

  // 验证MRR数据唯一性
  async validateUniqueMrrData(data: { companyId: string; monthYear: string; dataSourceId: string }) {
    // const exists = await mrrDataRepository.exists({
    //   companyId: data.companyId,
    //   monthYear: data.monthYear,
    //   dataSourceId: data.dataSourceId
    // });
    // if (exists) {
    //   throw new Error('MRR data for this company and month already exists');
    // }
  }
};

export default {
  companySchema,
  mrrDataSchema,
  investmentScoreSchema,
  dataSourceSchema,
  collectionTaskSchema,
  fundingRoundSchema,
  companyMetricsSchema,
  paginationSchema,
  companyFiltersSchema,
  mrrDataFiltersSchema,
  dateRangeSchema,
  validateData,
  validateDataAsync,
  formatZodError,
  customValidators
};