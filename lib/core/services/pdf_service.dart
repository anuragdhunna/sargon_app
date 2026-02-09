import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class PdfService {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  static Future<void> generateOrderBill(Order order, Bill? bill) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'SARGON RESTAURANT',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Order ID: ${order.id.split('_').last}'),
                  pw.Text('Date: ${_dateFormat.format(order.timestamp)}'),
                ],
              ),
              pw.Text('Table: ${order.tableNumber}'),
              if (order.guestName != null) pw.Text('Guest: ${order.guestName}'),
              if (order.waiterName != null)
                pw.Text('Waiter: ${order.waiterName}'),
              pw.Divider(),
              pw.SizedBox(height: 10),
              ...order.items.map(
                (item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${item.quantity}x ${item.name}'),
                    pw.Text('Rs. ${item.totalPrice.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              pw.Divider(),
              if (bill != null) ...[
                _buildSummaryRow('Subtotal', bill.subTotal),
                if (bill.taxSummary.serviceChargeAmount > 0)
                  _buildSummaryRow(
                    'Service Charge',
                    bill.taxSummary.serviceChargeAmount,
                  ),
                _buildSummaryRow('CGST', bill.taxSummary.cgstAmount),
                _buildSummaryRow('SGST', bill.taxSummary.sgstAmount),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Grand Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Rs. ${bill.grandTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ] else ...[
                _buildSummaryRow('Total', order.totalPrice),
              ],
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('Thank You! Visit Again')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generateConsolidatedFolio(
    String bookingId,
    List<Bill> bills,
    double posTotal,
    double totalPaid,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      _buildBasePage(
        title: 'Consolidated Folio',
        subtitle: 'Booking ID: $bookingId',
        content: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Bill ID', 'Date', 'Amount', 'Status'],
              data: bills
                  .map(
                    (b) => [
                      b.id.split('_').last,
                      _dateFormat.format(b.openedAt),
                      'Rs. ${b.grandTotal.toStringAsFixed(2)}',
                      b.paymentStatus.name.toUpperCase(),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            _buildSummaryRow('Total POS Charges', posTotal),
            _buildSummaryRow('Total Amount Paid', totalPaid),
            _buildSummaryRow('Remaining Balance', posTotal - totalPaid),
            pw.Divider(),
            pw.SizedBox(height: 40),
            _buildSignatureSection('Guest Signature', 'Manager Signature'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generatePurchaseOrder(PurchaseOrder po) async {
    final pdf = pw.Document();

    pdf.addPage(
      _buildBasePage(
        title: 'PURCHASE ORDER',
        subtitle: 'PO Number: ${po.poNumber}',
        content: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Vendor:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(po.vendorName ?? 'N/A'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Date:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(_dateFormat.format(po.createdAt)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Item Name', 'Unit', 'Qty', 'Price', 'Total'],
              data: po.lineItems
                  .map(
                    (item) => [
                      item.itemName,
                      item.unit.name,
                      item.orderedQuantity.toString(),
                      'Rs. ${item.pricePerUnit.toStringAsFixed(2)}',
                      'Rs. ${item.totalPrice.toStringAsFixed(2)}',
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            _buildSummaryRow('Total Amount', po.total),
            pw.Divider(),
            pw.SizedBox(height: 40),
            _buildSignatureSection('Authorized By', 'Vendor Acceptance'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generateGoodsReceiptNote(GoodsReceiptNote grn) async {
    final pdf = pw.Document();

    pdf.addPage(
      _buildBasePage(
        title: 'GOODS RECEIPT NOTE',
        subtitle: 'GRN Number: ${grn.grnNumber}',
        content: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Vendor:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(grn.vendorName ?? 'N/A'),
                    if (grn.purchaseOrderNumber != null)
                      pw.Text('Against PO: ${grn.purchaseOrderNumber}'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Received Date:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(_dateFormat.format(grn.receivedAt)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Item Name', 'Unit', 'Qty Recv', 'Price', 'Total'],
              data: grn.lineItems
                  .map(
                    (item) => [
                      item.itemName,
                      item.unit.name,
                      item.quantityReceived.toString(),
                      'Rs. ${item.pricePerUnit.toStringAsFixed(2)}',
                      'Rs. ${item.totalValue.toStringAsFixed(2)}',
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            _buildSummaryRow('Total Received Value', grn.totalValue),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text('Received By: ${grn.receivedByName}'),
            if (grn.deliveryPersonName != null)
              pw.Text('Delivered By: ${grn.deliveryPersonName}'),
            pw.SizedBox(height: 40),
            _buildSignatureSection('Receiver Signature', 'Store Manager'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Page _buildBasePage({
    required String title,
    String? subtitle,
    required pw.Widget content,
  }) {
    return pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'SARGON HOTEL & RESTAURANT',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Sector 12, Chandigarh, India | +91 9876543210',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (subtitle != null) pw.Text(subtitle),
              ],
            ),
            pw.SizedBox(height: 20),
            content,
            pw.Spacer(),
            pw.Divider(),
            pw.Center(
              child: pw.Text(
                'Generated on ${_dateFormat.format(DateTime.now())} | Powered by Sargon ERP',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static pw.Widget _buildSignatureSection(String leftLabel, String rightLabel) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Container(
              width: 150,
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide()),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(leftLabel, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Column(
          children: [
            pw.Container(
              width: 150,
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide()),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(rightLabel, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow(String label, double value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(
            'Rs. ${value.toStringAsFixed(2)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
