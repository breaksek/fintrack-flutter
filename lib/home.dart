import 'package:flutter/material.dart';

void main() {
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF10B981),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// Model data Transaksi tanpa Kategori
class Transaction {
  final String id;
  String title;
  double amount;
  bool isIncome;
  DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Data sampel awal
  final List<Transaction> _transactions = [
    Transaction(
      id: 't1',
      title: 'Gaji Bulanan',
      amount: 15000000,
      isIncome: true,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Transaction(
      id: 't2',
      title: 'Belanja Bulanan',
      amount: 1500000,
      isIncome: false,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: 't3',
      title: 'Beli Bensin',
      amount: 50000,
      isIncome: false,
      date: DateTime.now(),
    ),
  ];

  // Hitung total saldo
  double get _totalBalance {
    return _transactions.fold(0.0, (sum, item) {
      return item.isIncome ? sum + item.amount : sum - item.amount;
    });
  }

  // Hitung total pemasukan
  double get _totalIncome {
    return _transactions
        .where((item) => item.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Hitung total pengeluaran
  double get _totalExpense {
    return _transactions
        .where((item) => !item.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Helper format Rupiah sederhana tanpa package external
  String _formatRupiah(double amount) {
    String str = amount.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return 'Rp $result';
  }

  // Helper format Tanggal sederhana (DD/MM/YYYY)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // [CREATE] Tambah transaksi baru
  void _addTransaction(
      String title, double amount, bool isIncome, DateTime date) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      isIncome: isIncome,
      date: date,
    );

    setState(() {
      _transactions.insert(0, newTx);
    });
  }

  // [UPDATE] Edit transaksi
  void _editTransaction(String id, String newTitle, double newAmount,
      bool newIsIncome, DateTime newDate) {
    setState(() {
      final index = _transactions.indexWhere((tx) => tx.id == id);
      if (index >= 0) {
        _transactions[index].title = newTitle;
        _transactions[index].amount = newAmount;
        _transactions[index].isIncome = newIsIncome;
        _transactions[index].date = newDate;
      }
    });
  }

  // [DELETE] Hapus transaksi
  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
  }

  // Bottom sheet modal untuk Create & Update
  void _openTransactionModal(BuildContext ctx, [Transaction? txToEdit]) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return TransactionFormModal(
          txToEdit: txToEdit,
          onSave: (title, amount, isIncome, date) {
            if (txToEdit == null) {
              _addTransaction(title, amount, isIncome, date);
            } else {
              _editTransaction(txToEdit.id, title, amount, isIncome, date);
            }
          },
          onDelete:
              txToEdit != null ? () => _deleteTransaction(txToEdit.id) : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FinTrack',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- RINGKASAN SALDO ---
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(0xFF0F172A),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL SALDO',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatRupiah(_totalBalance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pemasukan',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                '+ ${_formatRupiah(_totalIncome)}',
                                style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Pengeluaran',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                '- ${_formatRupiah(_totalExpense)}',
                                style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- HEADER DAFTAR ---
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              // --- LIST TRANSAKSI (READ) ---
              _transactions.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'Belum ada transaksi.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length,
                      itemBuilder: (ctx, index) {
                        final tx = _transactions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          color: Colors.white,
                          child: ListTile(
                            onTap: () => _openTransactionModal(context, tx),
                            leading: CircleAvatar(
                              backgroundColor: tx.isIncome
                                  ? const Color(0xFFE6F4EA)
                                  : const Color(0xFFFCE8E6),
                              child: Icon(
                                tx.isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: tx.isIncome
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              tx.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              _formatDate(tx.date),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${tx.isIncome ? "+" : "-"} ${_formatRupiah(tx.amount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: tx.isIncome
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20, color: Colors.grey),
                                  onPressed: () => _deleteTransaction(tx.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTransactionModal(context),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Modal Form Tambah / Edit Transaksi
class TransactionFormModal extends StatefulWidget {
  final Transaction? txToEdit;
  final Function(String title, double amount, bool isIncome, DateTime date)
      onSave;
  final VoidCallback? onDelete;

  const TransactionFormModal({
    super.key,
    this.txToEdit,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<TransactionFormModal> createState() => _TransactionFormModalState();
}

class _TransactionFormModalState extends State<TransactionFormModal> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.txToEdit != null) {
      _titleController.text = widget.txToEdit!.title;
      _amountController.text = widget.txToEdit!.amount.toInt().toString();
      _isIncome = widget.txToEdit!.isIncome;
      _selectedDate = widget.txToEdit!.date;
    }
  }

  void _submitData() {
    final titleText = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (titleText.isEmpty || amountText.isEmpty) return;

    final enteredAmount = double.tryParse(amountText);
    if (enteredAmount == null || enteredAmount <= 0) return;

    widget.onSave(
      titleText,
      enteredAmount,
      _isIncome,
      _selectedDate,
    );

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.txToEdit != null;

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Edit Transaksi' : 'Tambah Transaksi Baru',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Toggle Pemasukan/Pengeluaran
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Pengeluaran')),
                  selected: !_isIncome,
                  selectedColor: const Color(0xFFEF4444),
                  labelStyle: TextStyle(
                      color: !_isIncome ? Colors.white : Colors.black),
                  onSelected: (selected) {
                    setState(() {
                      _isIncome = !selected;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Pemasukan')),
                  selected: _isIncome,
                  selectedColor: const Color(0xFF10B981),
                  labelStyle:
                      TextStyle(color: _isIncome ? Colors.white : Colors.black),
                  onSelected: (selected) {
                    setState(() {
                      _isIncome = selected;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Nama Transaksi',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jumlah (Rp)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          // Date Picker Tile
          InkWell(
            onTap: _presentDatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (isEditing)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      if (widget.onDelete != null) widget.onDelete!();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Hapus'),
                  ),
                ),
              if (isEditing) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _submitData,
                  child: Text(isEditing ? 'Simpan' : 'Tambah'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
