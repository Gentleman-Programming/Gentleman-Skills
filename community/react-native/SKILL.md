---
name: react-native
description: >
  React Native patterns for mobile app development with Expo and bare workflow.
  Trigger: When building mobile apps, working with React Native components, using Expo, React Navigation, or NativeWind.
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

Load this skill when:
- Building mobile applications with React Native
- Working with Expo managed or bare workflow
- Implementing navigation with React Navigation
- Styling with NativeWind (Tailwind for RN)
- Handling platform-specific code (iOS/Android)
- Managing native modules and linking

## Critical Patterns

### Pattern 1: Project Structure

```
src/
├── app/                    # Expo Router screens (if using)
│   ├── (tabs)/            # Tab navigator group
│   ├── (auth)/            # Auth flow group
│   └── _layout.tsx        # Root layout
├── components/
│   ├── ui/                # Reusable UI components
│   └── features/          # Feature-specific components
├── hooks/                 # Custom hooks
├── services/              # API and external services
├── stores/                # State management (Zustand)
├── utils/                 # Utility functions
├── constants/             # App constants, themes
└── types/                 # TypeScript types
```

### Pattern 2: Functional Components with TypeScript

Always use functional components with proper typing:

```typescript
import { View, Text, Pressable } from 'react-native';
import type { ViewStyle, TextStyle } from 'react-native';

interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export function Button({ 
  title, 
  onPress, 
  variant = 'primary',
  disabled = false 
}: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      style={({ pressed }) => [
        styles.button,
        variant === 'secondary' && styles.buttonSecondary,
        pressed && styles.buttonPressed,
        disabled && styles.buttonDisabled,
      ]}
    >
      <Text style={styles.buttonText}>{title}</Text>
    </Pressable>
  );
}
```

### Pattern 3: Platform-Specific Code

Use Platform module or file extensions for platform-specific code:

```typescript
import { Platform, StyleSheet } from 'react-native';

// Using Platform.select
const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.select({
      ios: 44,
      android: 0,
    }),
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
      },
      android: {
        elevation: 4,
      },
    }),
  },
});

// Or use file extensions:
// Component.ios.tsx
// Component.android.tsx
```

## Code Examples

### Example 1: Expo Router Navigation Setup

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="auto" />
      <Stack
        screenOptions={{
          headerShown: false,
          animation: 'slide_from_right',
        }}
      >
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen 
          name="modal" 
          options={{ 
            presentation: 'modal',
            animation: 'slide_from_bottom',
          }} 
        />
      </Stack>
    </>
  );
}
```

### Example 2: Custom Hook with React Query

```typescript
// hooks/useUser.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { userService } from '@/services/user';
import type { User, UpdateUserInput } from '@/types';

export function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => userService.getById(userId),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: UpdateUserInput) => userService.update(data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['user', variables.id] });
    },
  });
}
```

### Example 3: NativeWind Styling

```typescript
// With NativeWind (Tailwind for React Native)
import { View, Text, Pressable } from 'react-native';
import { styled } from 'nativewind';

const StyledPressable = styled(Pressable);
const StyledView = styled(View);
const StyledText = styled(Text);

export function Card({ title, description, onPress }: CardProps) {
  return (
    <StyledPressable
      className="bg-white dark:bg-gray-800 rounded-2xl p-4 shadow-md active:scale-95"
      onPress={onPress}
    >
      <StyledView className="flex-row items-center gap-3">
        <StyledView className="w-12 h-12 bg-blue-100 dark:bg-blue-900 rounded-full items-center justify-center">
          <StyledText className="text-blue-600 dark:text-blue-300 text-xl">
            📱
          </StyledText>
        </StyledView>
        <StyledView className="flex-1">
          <StyledText className="text-lg font-semibold text-gray-900 dark:text-white">
            {title}
          </StyledText>
          <StyledText className="text-sm text-gray-500 dark:text-gray-400">
            {description}
          </StyledText>
        </StyledView>
      </StyledView>
    </StyledPressable>
  );
}
```

### Example 4: Safe Area and Keyboard Handling

```typescript
import { KeyboardAvoidingView, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

export function ScreenWrapper({ children }: { children: React.ReactNode }) {
  return (
    <SafeAreaView style={{ flex: 1 }} edges={['top', 'left', 'right']}>
      <KeyboardAvoidingView
        style={{ flex: 1 }}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 20}
      >
        {children}
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
```

### Example 5: Zustand Store with Persistence

```typescript
// stores/authStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface AuthState {
  token: string | null;
  user: User | null;
  isAuthenticated: boolean;
  login: (token: string, user: User) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      isAuthenticated: false,
      login: (token, user) => set({ token, user, isAuthenticated: true }),
      logout: () => set({ token: null, user: null, isAuthenticated: false }),
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

## Anti-Patterns

### Don't: Inline Styles Everywhere

```typescript
// ❌ Bad - inline styles are hard to maintain and don't memoize
export function BadComponent() {
  return (
    <View style={{ flex: 1, padding: 16, backgroundColor: '#fff' }}>
      <Text style={{ fontSize: 18, fontWeight: 'bold', color: '#333' }}>
        Title
      </Text>
    </View>
  );
}

// ✅ Good - use StyleSheet or NativeWind
const styles = StyleSheet.create({
  container: { flex: 1, padding: 16, backgroundColor: '#fff' },
  title: { fontSize: 18, fontWeight: 'bold', color: '#333' },
});

export function GoodComponent() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Title</Text>
    </View>
  );
}
```

### Don't: Use TouchableOpacity for Everything

```typescript
// ❌ Bad - TouchableOpacity is legacy
import { TouchableOpacity } from 'react-native';

// ✅ Good - Use Pressable with feedback
import { Pressable } from 'react-native';

<Pressable
  onPress={onPress}
  style={({ pressed }) => [
    styles.button,
    pressed && { opacity: 0.7 }
  ]}
>
  {({ pressed }) => (
    <Text style={pressed ? styles.textPressed : styles.text}>
      Press Me
    </Text>
  )}
</Pressable>
```

### Don't: Forget to Handle Loading and Error States

```typescript
// ❌ Bad - no loading/error handling
export function UserProfile({ userId }: { userId: string }) {
  const { data } = useUser(userId);
  return <Text>{data.name}</Text>; // Will crash if data is undefined
}

// ✅ Good - handle all states
export function UserProfile({ userId }: { userId: string }) {
  const { data, isLoading, error } = useUser(userId);

  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!data) return null;

  return <Text>{data.name}</Text>;
}
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Create new Expo project | `npx create-expo-app@latest --template tabs` |
| Add NativeWind | `npx expo install nativewind tailwindcss` |
| Platform check | `Platform.OS === 'ios'` |
| Safe insets | `useSafeAreaInsets()` from `react-native-safe-area-context` |
| Navigation | `router.push('/screen')` with Expo Router |
| Deep linking | Configure in `app.json` under `expo.scheme` |
| Environment vars | Use `expo-constants` or `react-native-dotenv` |
| Icons | `@expo/vector-icons` (included in Expo) |
| Animations | `react-native-reanimated` for 60fps animations |
| Gestures | `react-native-gesture-handler` |

## Resources

- [Expo Documentation](https://docs.expo.dev/)
- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [Expo Router](https://expo.github.io/router/docs/)
- [NativeWind](https://www.nativewind.dev/)
- [React Navigation](https://reactnavigation.org/docs/getting-started)
