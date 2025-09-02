import { PrismaClient } from '@prisma/client';

declare global {
  // eslint-disable-next-line no-var
  var prisma: PrismaClient | undefined;
}

export const prisma = globalThis.prisma || new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

if (process.env.NODE_ENV !== 'production') {
  globalThis.prisma = prisma;
}

// 数据库健康检查
export async function checkDatabaseConnection() {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return { status: 'connected', timestamp: new Date() };
  } catch (error) {
    console.error('Database connection failed:', error);
    return { 
      status: 'disconnected', 
      error: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date() 
    };
  }
}

// 优雅关闭数据库连接
export async function closeDatabaseConnection() {
  await prisma.$disconnect();
}

// 数据库事务助手
export async function withTransaction<T>(
  callback: (tx: PrismaClient) => Promise<T>
): Promise<T> {
  return prisma.$transaction(callback);
}

// 批量操作助手
export const batchOperations = {
  // 批量插入MRR数据
  async batchInsertMrrData(data: any[]) {
    return prisma.mrrData.createMany({
      data,
      skipDuplicates: true
    });
  },

  // 批量更新企业信息
  async batchUpdateCompanies(updates: Array<{ id: string; data: any }>) {
    return Promise.all(
      updates.map(({ id, data }) =>
        prisma.company.update({ where: { id }, data })
      )
    );
  },

  // 批量删除过期数据
  async cleanupOldData(days: number = 90) {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);
    
    return Promise.all([
      prisma.collectionTask.deleteMany({
        where: {
          status: 'completed',
          completedAt: { lt: cutoffDate }
        }
      }),
      prisma.auditLog.deleteMany({
        where: {
          timestamp: { lt: cutoffDate }
        }
      })
    ]);
  }
};

export default prisma;