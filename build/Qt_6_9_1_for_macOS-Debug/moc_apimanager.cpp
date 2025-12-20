/****************************************************************************
** Meta object code from reading C++ file 'apimanager.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.9.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../apimanager.h"
#include <QtNetwork/QSslError>
#include <QtCore/qmetatype.h>
#include <QtCore/QList>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'apimanager.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN10ApiManagerE_t {};
} // unnamed namespace

template <> constexpr inline auto ApiManager::qt_create_metaobjectdata<qt_meta_tag_ZN10ApiManagerE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "ApiManager",
        "loginSuccess",
        "",
        "sessionToken",
        "maskedEmail",
        "loginFailed",
        "errorCode",
        "errorMessage",
        "otpVerifySuccess",
        "accessToken",
        "refreshToken",
        "user",
        "otpVerifyFailed",
        "registerSuccess",
        "userId",
        "email",
        "registerFailed",
        "forgotPasswordSuccess",
        "message",
        "forgotPasswordFailed",
        "resetPasswordSuccess",
        "resetPasswordFailed",
        "tokenRefreshed",
        "newAccessToken",
        "tokenRefreshFailed",
        "profileLoaded",
        "profileLoadFailed",
        "profileUpdated",
        "profileUpdateFailed",
        "passwordChanged",
        "passwordChangeFailed",
        "profileImageUploaded",
        "imageUrl",
        "profileImageUploadFailed",
        "profileImageRemoved",
        "profileImageRemoveFailed",
        "requestStarted",
        "requestFinished",
        "networkError",
        "onSslErrors",
        "QNetworkReply*",
        "reply",
        "QList<QSslError>",
        "errors"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'loginSuccess'
        QtMocHelpers::SignalData<void(const QString &, const QString &)>(1, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 3 }, { QMetaType::QString, 4 },
        }}),
        // Signal 'loginFailed'
        QtMocHelpers::SignalData<void(const QString &, const QString &)>(5, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 6 }, { QMetaType::QString, 7 },
        }}),
        // Signal 'otpVerifySuccess'
        QtMocHelpers::SignalData<void(const QString &, const QString &, const QJsonObject &)>(8, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 9 }, { QMetaType::QString, 10 }, { QMetaType::QJsonObject, 11 },
        }}),
        // Signal 'otpVerifyFailed'
        QtMocHelpers::SignalData<void(const QString &, const QString &)>(12, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 6 }, { QMetaType::QString, 7 },
        }}),
        // Signal 'registerSuccess'
        QtMocHelpers::SignalData<void(const QString &, const QString &)>(13, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 14 }, { QMetaType::QString, 15 },
        }}),
        // Signal 'registerFailed'
        QtMocHelpers::SignalData<void(const QString &, const QString &)>(16, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 6 }, { QMetaType::QString, 7 },
        }}),
        // Signal 'forgotPasswordSuccess'
        QtMocHelpers::SignalData<void(const QString &)>(17, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 18 },
        }}),
        // Signal 'forgotPasswordFailed'
        QtMocHelpers::SignalData<void(const QString &, const QString &)>(19, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 6 }, { QMetaType::QString, 7 },
        }}),
        // Signal 'resetPasswordSuccess'
        QtMocHelpers::SignalData<void()>(20, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'resetPasswordFailed'
        QtMocHelpers::SignalData<void(const QString &, const QString &)>(21, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 6 }, { QMetaType::QString, 7 },
        }}),
        // Signal 'tokenRefreshed'
        QtMocHelpers::SignalData<void(const QString &)>(22, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 23 },
        }}),
        // Signal 'tokenRefreshFailed'
        QtMocHelpers::SignalData<void()>(24, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'profileLoaded'
        QtMocHelpers::SignalData<void(const QJsonObject &)>(25, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QJsonObject, 11 },
        }}),
        // Signal 'profileLoadFailed'
        QtMocHelpers::SignalData<void(const QString &)>(26, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 7 },
        }}),
        // Signal 'profileUpdated'
        QtMocHelpers::SignalData<void(const QJsonObject &)>(27, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QJsonObject, 11 },
        }}),
        // Signal 'profileUpdateFailed'
        QtMocHelpers::SignalData<void(const QString &)>(28, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 7 },
        }}),
        // Signal 'passwordChanged'
        QtMocHelpers::SignalData<void()>(29, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'passwordChangeFailed'
        QtMocHelpers::SignalData<void(const QString &)>(30, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 7 },
        }}),
        // Signal 'profileImageUploaded'
        QtMocHelpers::SignalData<void(const QString &)>(31, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 32 },
        }}),
        // Signal 'profileImageUploadFailed'
        QtMocHelpers::SignalData<void(const QString &)>(33, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 7 },
        }}),
        // Signal 'profileImageRemoved'
        QtMocHelpers::SignalData<void()>(34, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'profileImageRemoveFailed'
        QtMocHelpers::SignalData<void(const QString &)>(35, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 7 },
        }}),
        // Signal 'requestStarted'
        QtMocHelpers::SignalData<void()>(36, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'requestFinished'
        QtMocHelpers::SignalData<void()>(37, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'networkError'
        QtMocHelpers::SignalData<void(const QString &)>(38, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 7 },
        }}),
        // Slot 'onSslErrors'
        QtMocHelpers::SlotData<void(QNetworkReply *, const QList<QSslError> &)>(39, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 40, 41 }, { 0x80000000 | 42, 43 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<ApiManager, qt_meta_tag_ZN10ApiManagerE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject ApiManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10ApiManagerE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10ApiManagerE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN10ApiManagerE_t>.metaTypes,
    nullptr
} };

void ApiManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<ApiManager *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->loginSuccess((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 1: _t->loginFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 2: _t->otpVerifySuccess((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QJsonObject>>(_a[3]))); break;
        case 3: _t->otpVerifyFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 4: _t->registerSuccess((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 5: _t->registerFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 6: _t->forgotPasswordSuccess((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 7: _t->forgotPasswordFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 8: _t->resetPasswordSuccess(); break;
        case 9: _t->resetPasswordFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 10: _t->tokenRefreshed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 11: _t->tokenRefreshFailed(); break;
        case 12: _t->profileLoaded((*reinterpret_cast< std::add_pointer_t<QJsonObject>>(_a[1]))); break;
        case 13: _t->profileLoadFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 14: _t->profileUpdated((*reinterpret_cast< std::add_pointer_t<QJsonObject>>(_a[1]))); break;
        case 15: _t->profileUpdateFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 16: _t->passwordChanged(); break;
        case 17: _t->passwordChangeFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 18: _t->profileImageUploaded((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 19: _t->profileImageUploadFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 20: _t->profileImageRemoved(); break;
        case 21: _t->profileImageRemoveFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 22: _t->requestStarted(); break;
        case 23: _t->requestFinished(); break;
        case 24: _t->networkError((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 25: _t->onSslErrors((*reinterpret_cast< std::add_pointer_t<QNetworkReply*>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QList<QSslError>>>(_a[2]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
        case 25:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 1:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QList<QSslError> >(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QNetworkReply* >(); break;
            }
            break;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & , const QString & )>(_a, &ApiManager::loginSuccess, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & , const QString & )>(_a, &ApiManager::loginFailed, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & , const QString & , const QJsonObject & )>(_a, &ApiManager::otpVerifySuccess, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & , const QString & )>(_a, &ApiManager::otpVerifyFailed, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & , const QString & )>(_a, &ApiManager::registerSuccess, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & , const QString & )>(_a, &ApiManager::registerFailed, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & )>(_a, &ApiManager::forgotPasswordSuccess, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & , const QString & )>(_a, &ApiManager::forgotPasswordFailed, 7))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)()>(_a, &ApiManager::resetPasswordSuccess, 8))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & , const QString & )>(_a, &ApiManager::resetPasswordFailed, 9))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & )>(_a, &ApiManager::tokenRefreshed, 10))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)()>(_a, &ApiManager::tokenRefreshFailed, 11))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QJsonObject & )>(_a, &ApiManager::profileLoaded, 12))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & )>(_a, &ApiManager::profileLoadFailed, 13))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QJsonObject & )>(_a, &ApiManager::profileUpdated, 14))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & )>(_a, &ApiManager::profileUpdateFailed, 15))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)()>(_a, &ApiManager::passwordChanged, 16))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & )>(_a, &ApiManager::passwordChangeFailed, 17))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & )>(_a, &ApiManager::profileImageUploaded, 18))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & )>(_a, &ApiManager::profileImageUploadFailed, 19))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)()>(_a, &ApiManager::profileImageRemoved, 20))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & )>(_a, &ApiManager::profileImageRemoveFailed, 21))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)()>(_a, &ApiManager::requestStarted, 22))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)()>(_a, &ApiManager::requestFinished, 23))
            return;
        if (QtMocHelpers::indexOfMethod<void (ApiManager::*)(const QString & )>(_a, &ApiManager::networkError, 24))
            return;
    }
}

const QMetaObject *ApiManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *ApiManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10ApiManagerE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int ApiManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 26)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 26;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 26)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 26;
    }
    return _id;
}

// SIGNAL 0
void ApiManager::loginSuccess(const QString & _t1, const QString & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 0, nullptr, _t1, _t2);
}

// SIGNAL 1
void ApiManager::loginFailed(const QString & _t1, const QString & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 1, nullptr, _t1, _t2);
}

// SIGNAL 2
void ApiManager::otpVerifySuccess(const QString & _t1, const QString & _t2, const QJsonObject & _t3)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 2, nullptr, _t1, _t2, _t3);
}

// SIGNAL 3
void ApiManager::otpVerifyFailed(const QString & _t1, const QString & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 3, nullptr, _t1, _t2);
}

// SIGNAL 4
void ApiManager::registerSuccess(const QString & _t1, const QString & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 4, nullptr, _t1, _t2);
}

// SIGNAL 5
void ApiManager::registerFailed(const QString & _t1, const QString & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 5, nullptr, _t1, _t2);
}

// SIGNAL 6
void ApiManager::forgotPasswordSuccess(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 6, nullptr, _t1);
}

// SIGNAL 7
void ApiManager::forgotPasswordFailed(const QString & _t1, const QString & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 7, nullptr, _t1, _t2);
}

// SIGNAL 8
void ApiManager::resetPasswordSuccess()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}

// SIGNAL 9
void ApiManager::resetPasswordFailed(const QString & _t1, const QString & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 9, nullptr, _t1, _t2);
}

// SIGNAL 10
void ApiManager::tokenRefreshed(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 10, nullptr, _t1);
}

// SIGNAL 11
void ApiManager::tokenRefreshFailed()
{
    QMetaObject::activate(this, &staticMetaObject, 11, nullptr);
}

// SIGNAL 12
void ApiManager::profileLoaded(const QJsonObject & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 12, nullptr, _t1);
}

// SIGNAL 13
void ApiManager::profileLoadFailed(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 13, nullptr, _t1);
}

// SIGNAL 14
void ApiManager::profileUpdated(const QJsonObject & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 14, nullptr, _t1);
}

// SIGNAL 15
void ApiManager::profileUpdateFailed(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 15, nullptr, _t1);
}

// SIGNAL 16
void ApiManager::passwordChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 16, nullptr);
}

// SIGNAL 17
void ApiManager::passwordChangeFailed(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 17, nullptr, _t1);
}

// SIGNAL 18
void ApiManager::profileImageUploaded(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 18, nullptr, _t1);
}

// SIGNAL 19
void ApiManager::profileImageUploadFailed(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 19, nullptr, _t1);
}

// SIGNAL 20
void ApiManager::profileImageRemoved()
{
    QMetaObject::activate(this, &staticMetaObject, 20, nullptr);
}

// SIGNAL 21
void ApiManager::profileImageRemoveFailed(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 21, nullptr, _t1);
}

// SIGNAL 22
void ApiManager::requestStarted()
{
    QMetaObject::activate(this, &staticMetaObject, 22, nullptr);
}

// SIGNAL 23
void ApiManager::requestFinished()
{
    QMetaObject::activate(this, &staticMetaObject, 23, nullptr);
}

// SIGNAL 24
void ApiManager::networkError(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 24, nullptr, _t1);
}
QT_WARNING_POP
