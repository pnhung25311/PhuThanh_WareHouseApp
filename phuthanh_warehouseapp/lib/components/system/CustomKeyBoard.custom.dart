import 'package:flutter/material.dart';

class SmartKeyboardDemo extends StatefulWidget {
  const SmartKeyboardDemo({super.key});

  @override
  State<SmartKeyboardDemo> createState() => _SmartKeyboardDemoState();
}

class _SmartKeyboardDemoState extends State<SmartKeyboardDemo>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  void _insertText(String text) {
    final selection = _controller.selection;
    final newText = _controller.text.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    final newPos = selection.start + text.length;
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newPos),
    );
  }

  void _backspace() {
    final selection = _controller.selection;
    if (selection.start == 0) return;

    final newText = _controller.text.replaceRange(
      selection.start - 1,
      selection.start,
      '',
    );

    final newPos = selection.start - 1;
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newPos),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            // 👇 Tap ra ngoài thì ẩn bàn phím
            GestureDetector(
              onTap: () {
                if (_focusNode.hasFocus) _focusNode.unfocus();
              },
              behavior: HitTestBehavior.translucent,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      showCursor: true,
                      readOnly: true, // chặn bàn phím hệ thống
                      decoration: const InputDecoration(
                        labelText: 'Nhập số giống TextInput',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 👇 Bàn phím custom
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _offsetAnimation,
                child: Material(
                  elevation: 20,
                  color: Colors.transparent,
                  child: _CustomKeyboard(
                    onTextInput: _insertText,
                    onBackspace: _backspace,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomKeyboard extends StatelessWidget {
  final Function(String) onTextInput;
  final VoidCallback onBackspace;

  const _CustomKeyboard({
    required this.onTextInput,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['-', '0', '.', '⌫'],
    ];

    return Material(
      elevation: 20,
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...keys.map((row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((key) {
                  return _buildKey(key);
                }).toList(),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String label) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          minimumSize: const Size(70, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          if (label == '⌫') {
            onBackspace();
          } else {
            onTextInput(label);
          }
        },
        child: Text(label, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
