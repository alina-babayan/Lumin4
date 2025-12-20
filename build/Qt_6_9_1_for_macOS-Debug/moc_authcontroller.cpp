/****************************************************************************
** Meta object code from reading C++ file 'authcontroller.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.9.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../authcontroller.h"
#include <QtNetwork/QSslError>
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'authcontroller.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.9.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN14AuthControllerE_t {};
} // unnamed namespace

template <> constexpr inline auto AuthController::qt_create_metaobjectdata<qt_meta_tag_ZN14AuthControllerE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "AuthController",
        "isLoadingChanged",
        "",
        "isLoggedInChanged",
        "errorMessageChanged",
        "maskedEmailChanged",
        "userNameChanged",
        "userEmailChanged",
        "userImageChanged",
        "userIdChanged",
        "loginSuccessful",
        "otpVerified",
        "registrationSuccessful",
        "passwordResetSent",
        "passwordResetSuccessful",
        "passwordChanged",
        "loggedOut",
        "onLoginSuccess",
        "sessionToken",
        "maskedEmail",
        "onLoginFailed",
        "errorCode",
        "errorMessage",
        "onOtpVerifySuccess",
        "accessToken",
        "refreshToken",
        "user",
        "onOtpVerifyFailed",
        "onRegisterSuccess",
        "userId",
        "email",
        "onRegisterFailed",
        "onForgotPasswordSuccess",
        "message",
        "onForgotPasswordFailed",
        "onResetPasswordSuccess",
        "onResetPasswordFailed",
        "onProfileLoaded",
        "onProfileLoadFailed",
        "onPasswordChanged",
        "onPasswordChangeFailed",
        "onRequestStarted",
        "onRequestFinished",
        "login",
        "password",
        "verifyOtp",
        "code",
        "resendOtp",
        "registerUser",
        "firstName",
        "lastName",
        "forgotPassword",
        "resetPassword",
        "token",
        "newPassword",
        "logout",
        "clearError",
        "loadProfile",
        "changePassword",
        "currentPassword",
        "isLoading",
        "isLoggedIn",
        "userName",
        "userEmail",
        "userImage"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'isLoadingChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'isLoggedInChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'errorMessageChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'maskedEmailChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'userNameChanged'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'userEmailChanged'
        QtMocHelpers::SignalData<void()>(7, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'userImageChanged'
        QtMocHelpers::SignalData<void()>(8, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'userIdChanged'
        QtMocHelpers::SignalData<void()>(9, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'loginSuccessful'
        QtMocHelpers::SignalData<void()>(10, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'otpVerified'
        QtMocHelpers::SignalData<void()>(11, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'registrationSuccessful'
        QtMocHelpers::SignalData<void()>(12, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'passwordResetSent'
        QtMocHelpers::SignalData<void()>(13, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'passwordResetSuccessful'
        QtMocHelpers::SignalData<void()>(14, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'passwordChanged'
        QtMocHelpers::SignalData<void()>(15, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'loggedOut'
        QtMocHelpers::SignalData<void()>(16, 2, QMC::AccessPublic, QMetaType::Void),
        // Slot 'onLoginSuccess'
        QtMocHelpers::SlotData<void(const QString &, const QString &)>(17, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 18 }, { QMetaType::QString, 19 },
        }}),
        // Slot 'onLoginFailed'
        QtMocHelpers::SlotData<void(const QString &, const QString &)>(20, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 21 }, { QMetaType::QString, 22 },
        }}),
        // Slot 'onOtpVerifySuccess'
        QtMocHelpers::SlotData<void(const QString &, const QString &, const QJsonObject &)>(23, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 24 }, { QMetaType::QString, 25 }, { QMetaType::QJsonObject, 26 },
        }}),
        // Slot 'onOtpVerifyFailed'
        QtMocHelpers::SlotData<void(const QString &, const QString &)>(27, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 21 }, { QMetaType::QString, 22 },
        }}),
        // Slot 'onRegisterSuccess'
        QtMocHelpers::SlotData<void(const QString &, const QString &)>(28, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 29 }, { QMetaType::QString, 30 },
        }}),
        // Slot 'onRegisterFailed'
        QtMocHelpers::SlotData<void(const QString &, const QString &)>(31, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 21 }, { QMetaType::QString, 22 },
        }}),
        // Slot 'onForgotPasswordSuccess'
        QtMocHelpers::SlotData<void(const QString &)>(32, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 33 },
        }}),
        // Slot 'onForgotPasswordFailed'
        QtMocHelpers::SlotData<void(const QString &, const QString &)>(34, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 21 }, { QMetaType::QString, 22 },
        }}),
        // Slot 'onResetPasswordSuccess'
        QtMocHelpers::SlotData<void()>(35, 2, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'onResetPasswordFailed'
        QtMocHelpers::SlotData<void(const QString &, const QString &)>(36, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 21 }, { QMetaType::QString, 22 },
        }}),
        // Slot 'onProfileLoaded'
        QtMocHelpers::SlotData<void(const QJsonObject &)>(37, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QJsonObject, 26 },
        }}),
        // Slot 'onProfileLoadFailed'
        QtMocHelpers::SlotData<void(const QString &)>(38, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 22 },
        }}),
        // Slot 'onPasswordChanged'
        QtMocHelpers::SlotData<void()>(39, 2, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'onPasswordChangeFailed'
        QtMocHelpers::SlotData<void(const QString &)>(40, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 22 },
        }}),
        // Slot 'onRequestStarted'
        QtMocHelpers::SlotData<void()>(41, 2, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'onRequestFinished'
        QtMocHelpers::SlotData<void()>(42, 2, QMC::AccessPrivate, QMetaType::Void),
        // Method 'login'
        QtMocHelpers::MethodData<void(const QString &, const QString &)>(43, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 30 }, { QMetaType::QString, 44 },
        }}),
        // Method 'verifyOtp'
        QtMocHelpers::MethodData<void(const QString &)>(45, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 46 },
        }}),
        // Method 'resendOtp'
        QtMocHelpers::MethodData<void()>(47, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'registerUser'
        QtMocHelpers::MethodData<void(const QString &, const QString &, const QString &, const QString &)>(48, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 49 }, { QMetaType::QString, 50 }, { QMetaType::QString, 30 }, { QMetaType::QString, 44 },
        }}),
        // Method 'forgotPassword'
        QtMocHelpers::MethodData<void(const QString &)>(51, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 30 },
        }}),
        // Method 'resetPassword'
        QtMocHelpers::MethodData<void(const QString &, const QString &)>(52, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 53 }, { QMetaType::QString, 54 },
        }}),
        // Method 'logout'
        QtMocHelpers::MethodData<void()>(55, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'clearError'
        QtMocHelpers::MethodData<void()>(56, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'loadProfile'
        QtMocHelpers::MethodData<void()>(57, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'changePassword'
        QtMocHelpers::MethodData<void(const QString &, const QString &)>(58, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 59 }, { QMetaType::QString, 54 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'isLoading'
        QtMocHelpers::PropertyData<bool>(60, QMetaType::Bool, QMC::DefaultPropertyFlags, 0),
        // property 'isLoggedIn'
        QtMocHelpers::PropertyData<bool>(61, QMetaType::Bool, QMC::DefaultPropertyFlags, 1),
        // property 'errorMessage'
        QtMocHelpers::PropertyData<QString>(22, QMetaType::QString, QMC::DefaultPropertyFlags, 2),
        // property 'maskedEmail'
        QtMocHelpers::PropertyData<QString>(19, QMetaType::QString, QMC::DefaultPropertyFlags, 3),
        // property 'userName'
        QtMocHelpers::PropertyData<QString>(62, QMetaType::QString, QMC::DefaultPropertyFlags, 4),
        // property 'userEmail'
        QtMocHelpers::PropertyData<QString>(63, QMetaType::QString, QMC::DefaultPropertyFlags, 5),
        // property 'userImage'
        QtMocHelpers::PropertyData<QString>(64, QMetaType::QString, QMC::DefaultPropertyFlags, 6),
        // property 'userId'
        QtMocHelpers::PropertyData<QString>(29, QMetaType::QString, QMC::DefaultPropertyFlags, 7),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<AuthController, qt_meta_tag_ZN14AuthControllerE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject AuthController::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN14AuthControllerE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN14AuthControllerE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN14AuthControllerE_t>.metaTypes,
    nullptr
} };

void AuthController::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<AuthController *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->isLoadingChanged(); break;
        case 1: _t->isLoggedInChanged(); break;
        case 2: _t->errorMessageChanged(); break;
        case 3: _t->maskedEmailChanged(); break;
        case 4: _t->userNameChanged(); break;
        case 5: _t->userEmailChanged(); break;
        case 6: _t->userImageChanged(); break;
        case 7: _t->userIdChanged(); break;
        case 8: _t->loginSuccessful(); break;
        case 9: _t->otpVerified(); break;
        case 10: _t->registrationSuccessful(); break;
        case 11: _t->passwordResetSent(); break;
        case 12: _t->passwordResetSuccessful(); break;
        case 13: _t->passwordChanged(); break;
        case 14: _t->loggedOut(); break;
        case 15: _t->onLoginSuccess((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 16: _t->onLoginFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 17: _t->onOtpVerifySuccess((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QJsonObject>>(_a[3]))); break;
        case 18: _t->onOtpVerifyFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 19: _t->onRegisterSuccess((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 20: _t->onRegisterFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 21: _t->onForgotPasswordSuccess((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 22: _t->onForgotPasswordFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 23: _t->onResetPasswordSuccess(); break;
        case 24: _t->onResetPasswordFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 25: _t->onProfileLoaded((*reinterpret_cast< std::add_pointer_t<QJsonObject>>(_a[1]))); break;
        case 26: _t->onProfileLoadFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 27: _t->onPasswordChanged(); break;
        case 28: _t->onPasswordChangeFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 29: _t->onRequestStarted(); break;
        case 30: _t->onRequestFinished(); break;
        case 31: _t->login((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 32: _t->verifyOtp((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 33: _t->resendOtp(); break;
        case 34: _t->registerUser((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[4]))); break;
        case 35: _t->forgotPassword((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 36: _t->resetPassword((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 37: _t->logout(); break;
        case 38: _t->clearError(); break;
        case 39: _t->loadProfile(); break;
        case 40: _t->changePassword((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::isLoadingChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::isLoggedInChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::errorMessageChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::maskedEmailChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::userNameChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::userEmailChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::userImageChanged, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::userIdChanged, 7))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::loginSuccessful, 8))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::otpVerified, 9))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::registrationSuccessful, 10))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::passwordResetSent, 11))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::passwordResetSuccessful, 12))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::passwordChanged, 13))
            return;
        if (QtMocHelpers::indexOfMethod<void (AuthController::*)()>(_a, &AuthController::loggedOut, 14))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<bool*>(_v) = _t->isLoading(); break;
        case 1: *reinterpret_cast<bool*>(_v) = _t->isLoggedIn(); break;
        case 2: *reinterpret_cast<QString*>(_v) = _t->errorMessage(); break;
        case 3: *reinterpret_cast<QString*>(_v) = _t->maskedEmail(); break;
        case 4: *reinterpret_cast<QString*>(_v) = _t->userName(); break;
        case 5: *reinterpret_cast<QString*>(_v) = _t->userEmail(); break;
        case 6: *reinterpret_cast<QString*>(_v) = _t->userImage(); break;
        case 7: *reinterpret_cast<QString*>(_v) = _t->userId(); break;
        default: break;
        }
    }
}

const QMetaObject *AuthController::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *AuthController::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN14AuthControllerE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int AuthController::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 41)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 41;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 41)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 41;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 8;
    }
    return _id;
}

// SIGNAL 0
void AuthController::isLoadingChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void AuthController::isLoggedInChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void AuthController::errorMessageChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void AuthController::maskedEmailChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void AuthController::userNameChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void AuthController::userEmailChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void AuthController::userImageChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void AuthController::userIdChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}

// SIGNAL 8
void AuthController::loginSuccessful()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}

// SIGNAL 9
void AuthController::otpVerified()
{
    QMetaObject::activate(this, &staticMetaObject, 9, nullptr);
}

// SIGNAL 10
void AuthController::registrationSuccessful()
{
    QMetaObject::activate(this, &staticMetaObject, 10, nullptr);
}

// SIGNAL 11
void AuthController::passwordResetSent()
{
    QMetaObject::activate(this, &staticMetaObject, 11, nullptr);
}

// SIGNAL 12
void AuthController::passwordResetSuccessful()
{
    QMetaObject::activate(this, &staticMetaObject, 12, nullptr);
}

// SIGNAL 13
void AuthController::passwordChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 13, nullptr);
}

// SIGNAL 14
void AuthController::loggedOut()
{
    QMetaObject::activate(this, &staticMetaObject, 14, nullptr);
}
QT_WARNING_POP
