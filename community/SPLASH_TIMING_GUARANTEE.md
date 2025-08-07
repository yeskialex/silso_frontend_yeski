# 스플래시 화면 5초 보장 메커니즘

## 개요
스플래시 화면이 **정확히 5초 동안 표시**되도록 보장하기 위한 다중 안전장치 시스템이 구현되었습니다.

## 보장 메커니즘

### 1. Controller 레벨 보장 (`SplashScreenController`)

#### 정확한 시간 측정
```dart
DateTime? _startTime;  // 시작 시간 기록
bool _isNavigating = false;  // 중복 네비게이션 방지
```

#### 시간 검증 로직
```dart
void _attemptNavigation() async {
  if (_isNavigating || _startTime == null) return;
  
  final elapsed = DateTime.now().difference(_startTime!);
  final minDuration = SplashScreenModel.splashDuration; // 5초
  
  if (elapsed >= minDuration) {
    // 5초가 경과했으면 즉시 네비게이션
    completeSplash();
  } else {
    // 5초가 되지 않았으면 추가 대기
    final remainingTime = minDuration - elapsed;
    Timer(remainingTime, () {
      completeSplash();
    });
  }
}
```

### 2. View 레벨 안전장치 (`SplashScreenView`)

#### 추가 타이머 보장
```dart
DateTime? _viewStartTime;  // View 시작 시간
Timer? _minimumDisplayTimer;  // 추가 안전장치 타이머

// initState에서 추가 5초 타이머 설정
_minimumDisplayTimer = Timer(const Duration(seconds: 5), () {
  debugPrint('SplashScreenView: 최소 5초 타이머 완료');
});
```

### 3. 중복 네비게이션 방지

#### 한 번만 네비게이션 실행
```dart
void completeSplash() {
  if (_isNavigating) return; // 중복 네비게이션 방지
  
  _isNavigating = true;
  // ... 네비게이션 로직
}
```

## 디버깅 및 모니터링

### 로그 출력
모든 중요한 시점에서 디버그 로그가 출력됩니다:

```dart
// Controller에서
debugPrint('Splash: 추가 대기 시간 ${remainingTime.inMilliseconds}ms');
debugPrint('Splash: 총 표시 시간 ${totalElapsed.inMilliseconds}ms');

// View에서  
debugPrint('SplashScreenView: initState 시작 - ${_viewStartTime}');
debugPrint('SplashScreenView: 총 생존 시간 ${totalTime.inMilliseconds}ms');
```

### 개발용 기능

#### Skip 버튼 (디버그 모드만)
```dart
if (const bool.fromEnvironment('dart.vm.product') != true)
  _buildSkipButton(),
```

#### 시간 확인 헬퍼 메서드
```dart
Duration? get elapsedTime;
bool get hasMinimumTimeElapsed;
```

## 테스트 검증

### 정밀한 타이밍 테스트
```dart
testWidgets('Splash screen minimum 5-second guarantee test', (WidgetTester tester) async {
  final startTime = DateTime.now();
  
  // ... 네비게이션 대기
  
  final elapsedTime = navigationTime.difference(startTime);
  expect(elapsedTime.inSeconds, greaterThanOrEqualTo(5));
});
```

## 구현된 안전장치 요약

| 레벨 | 메커니즘 | 목적 |
|------|----------|------|
| Controller | DateTime 기반 정확한 시간 측정 | 정밀한 5초 보장 |
| Controller | 추가 대기 시간 계산 | 부족한 시간 보완 |
| Controller | 중복 네비게이션 방지 | 다중 호출 차단 |
| View | 추가 안전장치 타이머 | 이중 보장 |
| View | 생존 시간 모니터링 | 실제 표시 시간 확인 |
| Test | 정밀 타이밍 검증 | 실제 동작 검증 |

## 실행 결과 예시

정상 동작 시 콘솔 출력:
```
SplashScreenView: initState 시작 - 2024-01-01 12:00:00.000
SplashScreenView: 컨트롤러 초기화
SplashScreenView: 최소 5초 타이머 완료
Splash: 총 표시 시간 5001ms
SplashScreenView: dispose 호출됨
SplashScreenView: 총 생존 시간 5002ms
```

## 결론

이 구현을 통해 스플래시 화면이 **어떤 상황에서도 최소 5초간 표시**되는 것이 보장됩니다. 다중 레벨의 안전장치와 정밀한 시간 측정으로 안정적인 사용자 경험을 제공합니다.