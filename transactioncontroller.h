#ifndef TRANSACTIONCONTROLLER_H
#define TRANSACTIONCONTROLLER_H

#include <QObject>
#include <QVariantList>
#include "apimanager.h"

class TransactionController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(double totalRevenue READ totalRevenue NOTIFY summaryChanged)
    Q_PROPERTY(double thisMonthRevenue READ thisMonthRevenue NOTIFY summaryChanged)
    Q_PROPERTY(int totalTransactions READ totalTransactions NOTIFY summaryChanged)
    Q_PROPERTY(QString formattedTotalRevenue READ formattedTotalRevenue NOTIFY summaryChanged)
    Q_PROPERTY(QString formattedThisMonthRevenue READ formattedThisMonthRevenue NOTIFY summaryChanged)
    Q_PROPERTY(QVariantList transactions READ transactions NOTIFY transactionsChanged)
    Q_PROPERTY(QString currentStatus READ currentStatus NOTIFY currentStatusChanged)
    Q_PROPERTY(QString searchQuery READ searchQuery NOTIFY searchQueryChanged)
    Q_PROPERTY(int currentPage READ currentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY paginationChanged)
    Q_PROPERTY(int limit READ limit NOTIFY limitChanged)

public:
    explicit TransactionController(QObject *parent = nullptr);
    ~TransactionController();

    bool isLoading() const { return m_isLoading; }
    QString errorMessage() const { return m_errorMessage; }
    double totalRevenue() const { return m_totalRevenue; }
    double thisMonthRevenue() const { return m_thisMonthRevenue; }
    int totalTransactions() const { return m_totalTransactions; }
    QString formattedTotalRevenue() const;
    QString formattedThisMonthRevenue() const;
    QVariantList transactions() const { return m_transactions; }
    QString currentStatus() const { return m_currentStatus; }
    QString searchQuery() const { return m_searchQuery; }
    int currentPage() const { return m_currentPage; }
    int totalPages() const { return m_totalPages; }
    int limit() const { return m_limit; }

    Q_INVOKABLE void loadTransactions();
    Q_INVOKABLE void setStatusFilter(const QString &status);
    Q_INVOKABLE void setSearchQuery(const QString &query);
    Q_INVOKABLE void nextPage();
    Q_INVOKABLE void previousPage();
    Q_INVOKABLE void goToPage(int page);
    Q_INVOKABLE void clearError();
    Q_INVOKABLE void refresh();

signals:
    void isLoadingChanged();
    void errorMessageChanged();
    void summaryChanged();
    void transactionsChanged();
    void currentStatusChanged();
    void searchQueryChanged();
    void currentPageChanged();
    void paginationChanged();
    void limitChanged();
    void transactionsLoaded();

private slots:
    void onTransactionsLoaded(const QJsonObject &data);
    void onTransactionsLoadFailed(const QString &errorMessage);
    void onRequestStarted();
    void onRequestFinished();

private:
    void setLoading(bool loading);
    void setError(const QString &error);
    QString formatCurrency(double amount) const;
    void updateSummary(const QJsonObject &summary);
    void updateTransactionsList(const QJsonArray &transactionsArray);
    void updatePagination(const QJsonObject &pagination);
    QString formatDateTime(const QString &dateString) const;
    QString formatRelativeTime(const QString &dateString) const;

    ApiManager *m_api;
    bool m_isLoading;
    QString m_errorMessage;
    double m_totalRevenue;
    double m_thisMonthRevenue;
    int m_totalTransactions;
    QVariantList m_transactions;
    QString m_currentStatus;
    QString m_searchQuery;
    int m_currentPage;
    int m_totalPages;
    int m_limit;
    int m_total;
};

#endif // TRANSACTIONCONTROLLER_H
