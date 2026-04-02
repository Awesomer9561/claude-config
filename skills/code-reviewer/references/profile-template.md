# Project Profile: {PROJECT_NAME}

**Generated:** {DATE}
**Last Updated:** {DATE}
**Root:** {ROOT_PATH}
**Remote:** {GIT_REMOTE_URL}
**Project ID:** {PROJECT_ID}

## Tech Stack

- **Language(s):** {e.g., C# (.NET 8), TypeScript, Python 3.12}
- **Framework(s):** {e.g., ASP.NET Core, React/Next.js, Django, Express}
- **Database:** {e.g., PostgreSQL, MongoDB, SQLite}
- **ORM/Data Access:** {e.g., Entity Framework Core, Prisma, SQLAlchemy}
- **Messaging:** {e.g., RabbitMQ, Redis Pub/Sub, Kafka}
- **Caching:** {e.g., Redis, In-memory}
- **Test Framework:** {e.g., xUnit + Moq, Jest, pytest}
- **Build Tool:** {e.g., dotnet CLI, npm/yarn, Poetry}
- **Build Command:** {e.g., npm run build, dotnet build, go build ./..., cargo build, make build}

## Architecture

- **Pattern:** {e.g., Clean Architecture, MVC, Microservices, Monolith, Modular Monolith}
- **Directory Structure:**
  ```
  {paste observed structure, 2-3 levels deep}
  ```
- **Key layers:** {e.g., Api -> Application -> Domain -> Infrastructure}
- **Dependency Injection:** {e.g., Constructor injection via built-in DI, Module imports}
- **API Style:** {e.g., REST, GraphQL, gRPC, Minimal APIs}

## Coding Conventions

- **Naming:**
  - Variables/fields: {e.g., camelCase, snake_case}
  - Methods/functions: {e.g., PascalCase, camelCase}
  - Classes/types: {e.g., PascalCase}
  - Files: {e.g., PascalCase.cs, kebab-case.ts}
  - Constants: {e.g., UPPER_SNAKE, PascalCase}
- **Import Style:** {e.g., Global usings in GlobalUsings.cs, barrel exports, absolute imports}
- **Formatting:** {e.g., Prettier, EditorConfig, ReSharper, Black}
- **Max function length:** {observed typical, e.g., ~50 lines}
- **Nullable types:** {e.g., enabled, strict mode}

## Error Handling

- **Pattern:** {e.g., try/catch with typed exceptions, Result<T> pattern, middleware}
- **Validation:** {e.g., FluentValidation, DataAnnotations, IValidatableObject, Zod}
- **Logging:** {e.g., ILogger<T>, structured logging, console.error}
- **HTTP errors:** {e.g., Problem Details (RFC 7807), custom error DTOs}

## Test Conventions

- **Location:** {e.g., Separate test projects (ServiceName.UnitTests), __tests__/ adjacent, tests/ mirror}
- **Naming:** {e.g., MethodName_Scenario_ExpectedResult, describe/it blocks}
- **Pattern:** {e.g., AAA (Arrange-Act-Assert), Given-When-Then}
- **Data generation:** {e.g., AutoFixture, Faker, factory functions}
- **Mocking:** {e.g., Moq, Jest mocks, unittest.mock}
- **DB testing:** {e.g., InMemory EF, Testcontainers, SQLite}

## Commit Style

- **Format:** {e.g., conventional commits, free-form, Jira prefix}
- **Examples from history:**
  ```
  {paste 3-5 representative commit messages}
  ```

## Project-Specific Rules

{Rules extracted from CLAUDE.md, lint configs, README, or team conventions.}
{Examples:}
- {e.g., All API responses must use the standard response wrapper}
- {e.g., Database access only through repository classes, never direct DbContext}
- {e.g., No "Credit" prefix on class names inside CreditService}
- {e.g., Don't commit launchSettings.json files}

## Custom Review Rules

{User-added rules go here. These override or supplement the standard checklist.}
{Leave empty on init -- user populates over time.}
