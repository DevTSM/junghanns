import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/enum/message.dart';
import 'package:junghanns/models/message.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:provider/provider.dart';

class Chat extends StatelessWidget{
  const Chat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderJunghanns>(
      builder: (BuildContext context, ProviderJunghanns controller, _)=>
      SizedBox(
        width: MediaQuery.of(context).size.width * .75,
        height: MediaQuery.of(context).size.height * .6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Chat", style: TextStyles.blueJ22Bold),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView( 
                controller: controller.scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: controller.messagesChat.map((e) => 
                    Align(
                      alignment: e.emisor == '' 
                        ? Alignment.centerRight 
                        : Alignment.centerLeft,
                      child:_itemMessage(e)
                    )
                  ).toList(),
                )
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _textField(controller)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: ()=> controller.addMessage(), 
                  child: const Icon(Icons.send, color: JunnyColor.green24)
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _textField(ProviderJunghanns controller){
    return TextFormField(
      controller: controller.messageChat,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyles.blueJ15SemiBold,
      keyboardType: TextInputType.text,
      onEditingComplete: () => controller.addMessage(),
      decoration: InputDecoration(
        hintText: "Mensaje",
        hintStyle: TextStyles.grey15Itw,
        filled: true,
        fillColor: ColorsJunghanns.white,
        contentPadding: const EdgeInsets.only(left: 12, top: 10),
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: ColorsJunghanns.lighGrey),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: ColorsJunghanns.blueJ),
          borderRadius: BorderRadius.circular(8),
        ),
      )
    );
  }
  Widget _itemMessage( MessageChat current ){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(top: 5),
          decoration: JunnyDecoration.orange255(8)
            .copyWith(color: current.emisor == '' 
              ? JunnyColor.green24 
              : JunnyColor.white
            ),
          child: Text(
            current.message,
            style: JunnyText.bluea4(FontWeight.w500, 14)
              .copyWith(color: current.emisor == '' ? JunnyColor.white : null)
          ),
        ),
        Text(
          current.estatus == EstatusMessage.enviado
          ? DateFormat(
              DateTime.now().difference(current.date).inDays > 0
                ? 'dd/MM/yyyy HH:mm'
                : 'HH:mm'
            ).format(current.date)
          : 'no enviado',
          style:  current.estatus == EstatusMessage.enviado
            ? JunnyText.grey_255(FontWeight.w500, 8)
            : JunnyText.red5c(8),
        ),
        const SizedBox(height: 5)
      ],
    );
  }
}
showChat(BuildContext context){
  showDialog(
    context: context,
    builder: (_) => const AlertDialog(
      contentPadding: EdgeInsets.all(10),
      content: Chat()
    )
  );
}