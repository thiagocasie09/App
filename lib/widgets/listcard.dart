import 'package:modernlogintute/widgets/card.dart';
import 'package:flutter/material.dart';

import 'package:modernlogintute/Data/data.dart';

class ListCard extends StatelessWidget {
  const ListCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: listCards.length,
        itemBuilder: (context, index) {
          return card(data: listCards[index]);
        });
  }
}
