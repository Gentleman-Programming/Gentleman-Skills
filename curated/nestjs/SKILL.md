---
name: nestjs
description: >
  NestJS + TypeScript enterprise patterns with strict type safety and SOLID principles.
  Trigger: When writing NestJS code - controllers, services, modules, DTOs, repositories.
license: Apache-2.0
metadata:
  author: samael
  version: "1.0"
---

## When to Use

Load this skill when:
- Creating new NestJS modules, controllers, services, or repositories
- Writing DTOs with validation decorators
- Setting up project structure and dependency injection
- Implementing error handling and logging
- Writing tests for NestJS applications
- Setting up database entities and TypeORM configuration

## Critical Patterns

### Architecture Flow (NEVER Skip)

```
Controllers → Services → Repositories → Database
```

### TypeScript Strict Mode (ZERO Exceptions)

- **NEVER use `any`** - Absolute prohibition
- **Explicit return types** for public methods
- **Interface over type alias** for objects
- **const over let** when possible
- **No implicit any** anywhere

### Controller Rules (HTTP ONLY)

- Handle ONLY request/response concerns
- Call services for ALL business logic
- Use DTOs with validation decorators
- Document ALL endpoints with Swagger/OpenAPI
- Return proper HTTP status codes

### Service Rules (Business Logic ONLY)

- Contain ALL business rules
- Be unit testable without HTTP layer
- NO direct Request/Response usage
- Use constructor dependency injection
- NO static methods (breaks DI)

### DTO & Validation (Mandatory)

- Use class-validator decorators
- Use class-transformer for transformation
- Include @ApiProperty() for documentation
- Whitelist option to strip unknown properties
- NEVER reuse DTOs for database entities

### Error Handling

- Use Nest HttpException or custom exceptions
- NO raw Error objects
- Centralize error mapping with filters
- Log errors with context

## Code Examples

### Controller Pattern

```typescript
@ApiTags('Users')
@Controller('users')
export class UserController {
    constructor(private readonly userService: UserService) {}

    @Post()
    @ApiOperation({ summary: 'Create a new user' })
    @ApiCreatedResponse({ type: UserResponseDto })
    @ApiBadRequestResponse({ description: 'Invalid input' })
    async createUser(
        @Body() createUserDto: CreateUserDto,
    ): Promise<UserResponseDto> {
        const user = await this.userService.createUser(createUserDto);
        return { message: 'User created', data: user };
    }
}
```

### Service Pattern

```typescript
@Injectable()
export class UserService {
    constructor(
        @InjectRepository(User)
        private userRepository: UserRepository,
        private emailService: EmailService,
    ) {}

    async createUser(createUserDto: CreateUserDto): Promise<User> {
        if (await this.userRepository.existsByEmail(createUserDto.email)) {
            throw new ConflictException('Email already exists');
        }
        const user = await this.userRepository.create(createUserDto);
        await this.emailService.sendWelcomeEmail(user.email);
        return user;
    }
}
```

### DTO Pattern

```typescript
export class CreateUserDto {
    @ApiProperty()
    @IsEmail()
    @IsNotEmpty()
    email: string;

    @ApiProperty()
    @IsString()
    @MinLength(8)
    @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    password: string;
}
```

### Repository Pattern

```typescript
@Injectable()
export class UserRepository {
    constructor(
        @InjectRepository(User)
        private ormRepository: Repository<User>,
    ) {}

    async findByEmail(email: string): Promise<User | null> {
        return this.ormRepository.findOne({ where: { email } });
    }
}
```

## Anti-Patterns

### Don't: Fat Controllers

```typescript
// ❌ BAD - Business logic in controller
@Post()
async createUser(@Body() dto: CreateUserDto): Promise<any> {
    // Validation logic should be in DTO
    if (dto.password.length < 8) {
        throw new BadRequestException('Password too short');
    }
    
    // Database logic should be in repository
    const user = this.userRepository.create(dto);
    await this.userRepository.save(user);
    
    // Business logic should be in service
    await this.emailService.sendWelcomeEmail(user.email);
    
    return user;
}
```

### Don't: Architecture Violations

```typescript
// ❌ BAD - Direct DB calls outside repository
@Injectable()
export class UserService {
    constructor(
        @InjectRepository(User)
        private userRepository: Repository<User>, // Direct TypeORM usage
    ) {}

    async findByEmail(email: string): Promise<User | null> {
        // Should be in repository layer
        return this.userRepository.findOne({ where: { email } });
    }
}
```

### Don't: TypeScript Violations

```typescript
// ❌ BAD - Using any and implicit types
export class UserController {
    constructor(private readonly userService: UserService) {}

    @Get(':id')
    async getUser(@Param('id') id: any): Promise<any> {
        // Missing explicit types, using any
        return this.userService.getUser(id);
    }
}
```

### Don't: Security Issues

```typescript
// ❌ BAD - Unvalidated inputs and hardcoded secrets
export class AuthController {
    async login(@Body() loginDto: any): Promise<any> {
        // No validation decorator usage
        const user = await this.userService.validateUser(
            loginDto.email, 
            loginDto.password
        );
        
        // Hardcoded secret
        const token = jwt.sign({ userId: user.id }, 'hardcoded-secret');
        
        return { token };
    }
}
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Generate resource | `nest g resource users` |
| Controller | `@Controller()`, `@Get()`, `@Post()`, `@Body()` |
| Service | `@Injectable()`, constructor DI |
| DTO Validation | `class-validator`, `@IsEmail()`, `@IsNotEmpty()` |
| Repository | `@InjectRepository()`, TypeORM methods |
| Error Handling | `HttpException`, `@Catch()`, ExceptionFilter |
| Testing | `@Test()`, Mock dependencies, unit tests for services |
| Documentation | `@ApiTags()`, `@ApiOperation()`, `@ApiResponse()` |

## Project Structure

```
src/
├── core/                    # Core infrastructure (auth, config)
├── shared/                  # Shared utilities, common modules
├── features/                # Business features
│   ├── user/
│   │   ├── dto/
│   │   ├── entities/
│   │   ├── repositories/
│   │   ├── user.controller.ts
│   │   ├── user.service.ts
│   │   ├── user.module.ts
│   │   └── *.spec.ts
│   └── patient/
├── config/
├── common/
│   ├── decorators/
│   ├── filters/
│   ├── guards/
│   ├── interceptors/
│   └── pipes/
└── main.ts
```

## Testing Patterns

### Unit Test Structure

```typescript
describe('UserService', () => {
    let service: UserService;
    let repository: jest.Mocked<UserRepository>;

    beforeEach(async () => {
        const module = await Test.createTestingModule({
            providers: [
                UserService,
                {
                    provide: UserRepository,
                    useValue: {
                        findByEmail: jest.fn(),
                        create: jest.fn(),
                        existsByEmail: jest.fn(),
                    },
                },
            ],
        }).compile();

        service = module.get<UserService>(UserService);
        repository = module.get(UserRepository);
    });

    describe('createUser', () => {
        it('should create user successfully', async () => {
            // Arrange
            const createUserDto: CreateUserDto = {
                email: 'test@example.com',
                password: 'password123',
            };
            repository.existsByEmail.mockResolvedValue(false);
            repository.create.mockResolvedValue({ id: '1', ...createUserDto });

            // Act
            const result = await service.createUser(createUserDto);

            // Assert
            expect(repository.existsByEmail).toHaveBeenCalledWith(createUserDto.email);
            expect(repository.create).toHaveBeenCalledWith(createUserDto);
            expect(result).toEqual({ id: '1', ...createUserDto });
        });
    });
});
```

### Testing Requirements

- Services must have unit tests when business logic exists
- Controllers must have E2E tests for endpoints
- Coverage > 90% for business logic
- Test all HTTP status codes
- Test validation errors

## Commands

```bash
# Generate new resource (creates controller, service, module, DTOs)
nest g resource users

# Generate individual components
nest g module users
nest g controller users
nest g service users

# Check for circular dependencies
nest graph

# Run tests with coverage
npm run test:cov

# Run E2E tests
npm run test:e2e

# Build and validate TypeScript
npm run build
```