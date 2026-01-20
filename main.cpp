#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include "authcontroller.h"
#include "dashboardcontroller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setOrganizationName("PicsartAcademy");
    app.setOrganizationDomain("picsart.academy");
    app.setApplicationName("Lumin");
    app.setApplicationDisplayName("Picsart Academy - Lumin");
    app.setApplicationVersion("1.0.0");

    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;

    // Register controllers
    AuthController authController;
    DashboardController dashboardController;

    engine.rootContext()->setContextProperty("authController", &authController);
    engine.rootContext()->setContextProperty("dashboardController", &dashboardController);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    const QUrl url(QStringLiteral("qrc:/new/prefix1/Main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl) {
                             qCritical() << "Failed to load QML file:" << url;
                             QCoreApplication::exit(-1);
                         }
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
