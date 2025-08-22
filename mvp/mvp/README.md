# SilSo MVP - Flutter 앱 개발

Flutter를 기반으로 한 SilSo 모바일 애플리케이션 MVP 프로젝트입니다.

## 최근 개발 현황 (2025-08-21)

### 로그인 플로우 작업 완료 사항
1. **로그인/회원가입 페이지 UI 개선**
   - 새로운 버튼 배치 및 구현 (`lib/screens/login/login_screen.dart`)
   - 사용자 인터페이스 최적화

2. **ID/비밀번호 커스텀 로그인 시스템**
   - 새로운 페이지 구현 (`lib/screens/login/id_password_signup.dart`)
   - Firebase 'users' collection에 새로운 속성 추가

3. **중복 검사 로직 구현**
   - ID 중복 확인 기능
   - 비밀번호 유효성 검사

4. **로그인 유형별 플로우 분기**
   - 로그인 성공 경로
   - 회원가입 경로
   - 익명 로그인 경로
   - 각 유형별 다른 진입점 구현

### 현재 이슈
- **모바일 소셜 로그인 문제**: Kakao, Google 안드로이드에서 실행되지 않음

### 다음 작업 예정
- **펫 선택 기능 구현** (`lib/screens/login/mypet_select.dart`)

## 프로젝트 구조

```
lib/screens/login/
├── login_screen.dart          # 메인 로그인 화면
├── id_password_signup.dart    # ID/비밀번호 회원가입
├── mypet_select.dart         # 펫 선택 화면 (구현 예정)
├── phone_confirm.dart        # 전화번호 인증
├── policy_agreement_screen.dart # 약관 동의
├── category_selection_screen.dart # 카테고리 선택
└── after_signup_splash.dart  # 가입 완료 스플래시
```

## 개발 환경 설정

Flutter 개발을 처음 시작하는 경우 다음 리소스를 참고하세요:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

Flutter 개발에 대한 자세한 정보는 [공식 문서](https://docs.flutter.dev/)를 참고하세요.
