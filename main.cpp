#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QDebug>
#include "authcontroller.h"
#include "dashboardcontroller.h"

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

    AuthController authController;
    DashboardController dashboardController;

    qDebug() << "Controllers created";

    engine.rootContext()->setContextProperty("authController", &authController);
    engine.rootContext()->setContextProperty("dashboardController", &dashboardController);

    qDebug() << "Context properties set";

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
