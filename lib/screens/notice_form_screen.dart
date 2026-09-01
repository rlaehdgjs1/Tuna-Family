import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import '../models/notice.dart';
import '../models/poll.dart';
import '../providers/notice_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/media_view_helper.dart';

class NoticeFormScreen extends StatefulWidget {
  final Notice? noticeToEdit;

  const NoticeFormScreen({
    super.key,
    this.noticeToEdit,
  });

  @override
  State<NoticeFormScreen> createState() => _NoticeFormScreenState();
}

class _NoticeFormScreenState extends State<NoticeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late TextEditingController _videoUrlController;

  late NoticeCategory _selectedCategory;
  late bool _isPinned;

  // Media state
  final List<String> _imageUrls = [];

  // Poll state
  bool _includePoll = false;
  late TextEditingController _pollQuestionController;
  bool _pollIsMultiple = false;
  final List<TextEditingController> _pollOptionControllers = [];

  @override
  void initState() {
    super.initState();
    final n = widget.noticeToEdit;

    _titleController = TextEditingController(text: n?.title ?? '');
    _contentController = TextEditingController(text: n?.content ?? '');
    _tagsController = TextEditingController(text: n?.tags.join(', ') ?? '');
    _videoUrlController = TextEditingController(text: n?.videoUrl ?? '');
    _selectedCategory = n?.category ?? NoticeCategory.notice;
    _isPinned = n?.isPinned ?? false;

    if (n != null && n.imageUrls.isNotEmpty) {
      _imageUrls.addAll(n.imageUrls);
    }

    if (n?.poll != null) {
      _includePoll = true;
      _pollQuestionController =
          TextEditingController(text: n!.poll!.question);
      _pollIsMultiple = n.poll!.isMultipleChoice;
      for (final opt in n.poll!.options) {
        _pollOptionControllers.add(TextEditingController(text: opt.text));
      }
    } else {
      _pollQuestionController = TextEditingController();
      _pollOptionControllers.add(TextEditingController(text: '참석합니다! 👍'));
      _pollOptionControllers.add(TextEditingController(text: '불참합니다 😢'));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _videoUrlController.dispose();
    _pollQuestionController.dispose();
    for (final c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
      );
      if (result.isNotEmpty) {
        for (final file in result) {
          Uint8List? bytes;
          try {
            bytes = await file.readAsBytes();
          } catch (_) {}

          if (bytes != null) {
            final ext = file.extension?.toLowerCase() ?? 'png';
            final base64String = base64Encode(bytes);
            setState(() {
              _imageUrls.add('data:image/$ext;base64,$base64String');
            });
          } else if (file.path != null) {
            setState(() {
              _imageUrls.add(file.path!);
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 선택 오류: $e')),
        );
      }
    }
  }

  void _showAddImageUrlDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('사진 웹 링크(URL) 추가'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/photo.jpg',
            labelText: '이미지 URL',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                setState(() => _imageUrls.add(url));
                Navigator.pop(ctx);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _applyTemplate(String title, String content, NoticeCategory category,
      {bool hasPoll = false,
      String? pollQ,
      List<String>? pollOpts,
      String? videoUrl}) {
    setState(() {
      _titleController.text = title;
      _contentController.text = content;
      _selectedCategory = category;
      if (videoUrl != null) {
        _videoUrlController.text = videoUrl;
      }
      if (hasPoll && pollQ != null && pollOpts != null) {
        _includePoll = true;
        _pollQuestionController.text = pollQ;
        for (final c in _pollOptionControllers) {
          c.dispose();
        }
        _pollOptionControllers.clear();
        for (final opt in pollOpts) {
          _pollOptionControllers.add(TextEditingController(text: opt));
        }
      }
    });
  }

  void _saveNotice() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<NoticeProvider>();
    final currentMember = provider.currentMember;

    // Parse tags
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    // Construct poll if enabled
    Poll? poll;
    if (_includePoll) {
      final validOptionTexts = _pollOptionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (validOptionTexts.length >= 2) {
        final existingPoll = widget.noticeToEdit?.poll;
        final pollOptions = validOptionTexts.map((text) {
          final existingOpt = existingPoll?.options.firstWhere(
            (o) => o.text == text,
            orElse: () =>
                PollOption(id: const Uuid().v4(), text: text),
          );

          return PollOption(
            id: existingOpt?.id ?? const Uuid().v4(),
            text: text,
            voterMemberIds: existingOpt?.voterMemberIds ?? [],
          );
        }).toList();

        poll = Poll(
          id: existingPoll?.id ?? const Uuid().v4(),
          question: _pollQuestionController.text.trim().isNotEmpty
              ? _pollQuestionController.text.trim()
              : '가족 투표에 참여해 주세요!',
          options: pollOptions,
          isMultipleChoice: _pollIsMultiple,
        );
      }
    }

    final videoUrl = _videoUrlController.text.trim().isNotEmpty
        ? _videoUrlController.text.trim()
        : null;

    if (widget.noticeToEdit == null) {
      // Create new Notice
      final newNotice = Notice(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: currentMember.id,
        authorName: currentMember.nickname,
        authorEmoji: currentMember.emoji,
        category: _selectedCategory,
        isPinned: _isPinned,
        createdAt: DateTime.now(),
        tags: tags,
        poll: poll,
        imageUrls: List.from(_imageUrls),
        videoUrl: videoUrl,
        readMemberIds: [
          currentMember.id
        ], // Creator automatically marked as read
      );

      provider.addNotice(newNotice);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('새 공지가 등록되었습니다! 📢'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Update existing Notice
      final updatedNotice = widget.noticeToEdit!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        isPinned: _isPinned,
        tags: tags,
        poll: poll,
        imageUrls: List.from(_imageUrls),
        videoUrl: videoUrl,
      );

      provider.updateNotice(updatedNotice);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공지가 성공적으로 수정되었습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.noticeToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '공지 수정' : '새 공지 작성'),
        actions: [
          TextButton(
            onPressed: _saveNotice,
            child: Text(
              isEditing ? '수정완료' : '등록',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Template selector for quick setup
            if (!isEditing) ...[
              const Text(
                '빠른 공지 템플릿',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      label: const Text('📢 기본 공지사항'),
                      onPressed: () => _applyTemplate(
                        '📢 [공지] 가족 공지사항 안내',
                        '''참치패밀리 구성원 여러분 안내드립니다!

[공지 내용]
- 내용 입력...

확인하신 분은 하단의 '확인했어요' 버튼을 눌러주세요.''',
                        NoticeCategory.notice,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Text('🗓️ 가족 모임/일정'),
                      onPressed: () => _applyTemplate(
                        '🍽️ [공지] 이번 주말 가족 모임 일정 및 메뉴 투표',
                        '''참치패밀리 주말 가족모임 안내입니다!

📍 일시: 이번 주 토요일 18:30
📍 장소: (아래 투표 결과에 따라 결정)

모두 참석 부탁드리며 원하는 메뉴를 투표해 주세요!''',
                        NoticeCategory.notice,
                        hasPoll: true,
                        pollQ: '가족모임 식사 메뉴를 골라주세요!',
                        pollOpts: ['참치 코스요리 🐟', '소고기 구이 🥩', '중식 코스 🥟'],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Text('✈️ 가족 여행/행사'),
                      onPressed: () => _applyTemplate(
                        '✈️ [공지] 참치패밀리 가족 여행 일정 안내',
                        '''가족 여행 및 행사 일정 공유합니다!

📍 일시: 
📍 장소: 
📍 준비물: 

확인 후 확인 버튼을 눌러주세요!''',
                        NoticeCategory.notice,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Pinned Notice Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isPinned
                    ? AppColors.secondary.withValues(alpha: 0.08)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isPinned
                      ? AppColors.secondary.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
              child: SwitchListTile(
                value: _isPinned,
                onChanged: (val) => setState(() => _isPinned = val),
                title: const Text(
                  '📌 최상단 중요 공지로 고정',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  '홈 화면 상단 배너에 항상 고정 노출됩니다.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),

            // Title Field
            const Text(
              '공지 제목',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '공지 제목을 입력하세요 (예: 🐟 주말 가족 모임 안내)',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '공지 제목을 입력해 주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Content Field
            const Text(
              '공지 본문 내용',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 7,
              decoration: const InputDecoration(
                hintText: '가족들에게 전달할 공지 상세 내용을 작성해 주세요.\n(일정, 장소, 준비물, 전달사항 등)',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '공지 본문 내용을 입력해 주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Photo Attachment Section (User Request!) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_photo_alternate_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '사진 첨부 (${_imageUrls.length}장)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.photo_library_rounded,
                                size: 16),
                            label: const Text('내 폰에서 선택'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.link_rounded,
                                size: 20, color: AppColors.primary),
                            tooltip: 'URL 링크로 추가',
                            onPressed: _showAddImageUrlDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageUrls.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: MediaViewHelper.buildSingleImage(
                                    _imageUrls[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _imageUrls.removeAt(index));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Video Link Section (User Request!) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.video_library_rounded,
                          color: Color(0xFFE50914), size: 20),
                      SizedBox(width: 8),
                      Text(
                        '동영상 링크 첨부 (YouTube / 웹 영상)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _videoUrlController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'https://www.youtube.com/watch?v=... 또는 동영상 URL',
                      prefixIcon: const Icon(Icons.link_rounded,
                          color: AppColors.textSecondary, size: 20),
                      suffixIcon: _videoUrlController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _videoUrlController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                  // Real-time video preview
                  if (_videoUrlController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    MediaViewHelper.buildVideoCard(
                      context,
                      _videoUrlController.text.trim(),
                      isCard: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tags Field
            const Text(
              '해시태그 (쉼표로 구분)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                hintText: '예: 가족모임, 공지, 식사',
                prefixIcon:
                    Icon(Icons.tag_rounded, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),

            // Poll Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _includePoll
                    ? AppColors.primaryLight.withValues(alpha: 0.2)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _includePoll
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.how_to_vote_rounded,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '가족 투표 첨부하기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Switch(
                        value: _includePoll,
                        onChanged: (val) =>
                            setState(() => _includePoll = val),
                      ),
                    ],
                  ),
                  if (_includePoll) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pollQuestionController,
                      decoration: const InputDecoration(
                        labelText: '투표 질문',
                        hintText: '예: 참석 여부를 선택해 주세요',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _pollIsMultiple,
                      onChanged: (val) =>
                          setState(() => _pollIsMultiple = val ?? false),
                      title: const Text(
                        '복수 선택 허용',
                        style: TextStyle(fontSize: 13),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '선택지 목록:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pollOptionControllers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                '${index + 1}.',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _pollOptionControllers[index],
                                  decoration: InputDecoration(
                                    hintText: '선택지 ${index + 1}',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ),
                              if (_pollOptionControllers.length > 2) ...[
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.error,
                                      size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _pollOptionControllers[index].dispose();
                                      _pollOptionControllers.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    if (_pollOptionControllers.length < 6)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _pollOptionControllers
                                .add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('선택지 추가'),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            ElevatedButton(
              onPressed: _saveNotice,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isEditing ? '공지 수정 완료' : '공지 등록하기 📢',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
