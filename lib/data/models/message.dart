enum MessageMedia { Text, Image, Video, Audio, Misc }

class TheMessage {
  bool isStub = false;
  int messageId;
  String messageText;
  MessageMedia mediaType;
  String senderName;
  String senderImage;
  String date;
  int attachmentCount;
  List<MessageAttachments> attachments;


  TheMessage.name(this.isStub);

  TheMessage(this.messageId, this.messageText, this.mediaType, this.senderName,
      this.senderImage, this.date, this.attachmentCount, this.attachments);

  factory TheMessage.fromJson(Map<String, dynamic> item) {
    return TheMessage(
        int.parse(item['message_id']),
        item['message_text'],
        item['message_media_type'] == 'Text'
            ? getMsgMediaType(item['message_media_type'])
            : getMsgMediaType(item['file_media_type']),
        item['sender_name'],
        item['sender_image'],
        item['date'],
        int.parse(item['attachment_count']),
        [MessageAttachments(item['file'], item['file_media_type'])]);
  }

  static MessageMedia getMsgMediaType(fileMediaType) {
    switch (fileMediaType) {
      case "image":
        return MessageMedia.Image;
      case "video":
        return MessageMedia.Video;
      case "audio":
        return MessageMedia.Audio;
      default:
        return MessageMedia.Text;
    }
  }
}

class MessageAttachments {
  String fileUrl;
  String mediaType;

  MessageAttachments(this.fileUrl, this.mediaType);
}
