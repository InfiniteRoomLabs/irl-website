import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const services = defineCollection({
    loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/services' }),
    schema: z.object({
        title: z.string(),
        summary: z.string(),
        order: z.number().default(0),
        priceRange: z.string().optional(),
        serviceType: z.string().optional(),
    }),
});

const posts = defineCollection({
    loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/posts' }),
    schema: z.object({
        title: z.string(),
        description: z.string(),
        pubDate: z.coerce.date(),
        updatedDate: z.coerce.date().optional(),
        tags: z.array(z.string()).default([]),
        draft: z.boolean().default(false),
    }),
});

const caseStudies = defineCollection({
    loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/caseStudies' }),
    schema: z.object({
        title: z.string(),
        client: z.string(),
        summary: z.string(),
        problem: z.string(),
        solution: z.string(),
        outcome: z.string(),
        techStack: z.array(z.string()).default([]),
        pubDate: z.coerce.date(),
    }),
});

const faqs = defineCollection({
    loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/faqs' }),
    schema: z.object({
        question: z.string(),
        category: z.string().optional(),
        order: z.number().default(0),
    }),
});

const projects = defineCollection({
    loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/projects' }),
    schema: z.object({
        title: z.string(),
        tagline: z.string(),
        summary: z.string(),
        role: z.string(),
        tech: z.array(z.string()).default([]),
        repoUrl: z.string().url().optional(),
        order: z.number().default(0),
    }),
});

export const collections = { services, posts, caseStudies, faqs, projects };
