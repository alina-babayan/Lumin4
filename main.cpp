#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QDebug>
#include "authcontroller.h"
#include "dashboardcontroller.h"
#include "instructorcontroller.h"
#include "coursecontroller.h"
#include "usercontroller.h"
#include "transactioncontroller.h"
#include "notificationcontroller.h"

int main(int argc, char *argv[])
{
    qDebug() << "Application starting...";

    QGuiApplication app(argc, argv);

    app.setOrganizationName("PicsartAcademy");
    app.setOrganizationDomain("picsart.academy");
    app.setApplicationName("Lumin");
    app.setApplicationDisplayName("Picsart Academy - Lumin");
    app.setApplicationVersion("1.0.0");

    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;

    // Create all controllers
    AuthController *authController = new AuthController(&engine);
    DashboardController *dashboardController = new DashboardController(&engine);
    InstructorController *instructorController = new InstructorController(&engine);
    CourseController *courseController = new CourseController(&engine);
    UserController *userController = new UserController(&engine);
    TransactionController *transactionController = new TransactionController(&engine);
    NotificationController *notificationController = new NotificationController(&engine);

    qDebug() << "Controllers created";

    // Set context properties
    engine.rootContext()->setContextProperty("authController", authController);
    engine.rootContext()->setContextProperty("dashboardController", dashboardController);
    engine.rootContext()->setContextProperty("instructorController", instructorController);
    engine.rootContext()->setContextProperty("courseController", courseController);
    engine.rootContext()->setContextProperty("userController", userController);
    engine.rootContext()->setContextProperty("transactionController", transactionController);
    engine.rootContext()->setContextProperty("notificationController", notificationController);

    qDebug() << "Context properties set";

    // Verify controllers
    QObject *testAuth = engine.rootContext()->contextProperty("authController").value<QObject*>();
    qDebug() << "authController verification:" << (testAuth != nullptr ? "OK" : "NULL");

    const QUrl url(QStringLiteral("qrc:/new/prefix1/Main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() {
                         qCritical() << "Object creation failed!";
                         QCoreApplication::exit(-1);
                     },
                     Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load QML!";
        return -1;
    }

    qDebug() << "QML loaded successfully";

    return app.exec();
}
