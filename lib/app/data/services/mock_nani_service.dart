import 'package:nursing_nani_app/app/data/models/nani_models.dart';

class MockNaniService {
  MockNaniService();

  final Map<String, CareClockInDraft> _clockInDrafts = {};

  final NaniUser defaultUser = const NaniUser(
    id: 'caregiver-001',
    name: '林晓雯',
    role: '责任护工',
    station: '2号楼 A 区护理站',
  );

  final ShiftOverview shiftOverview = const ShiftOverview(
    caregiverName: '林晓雯',
    station: '2号楼 A 区护理站',
    shiftLabel: '白班 07:30 - 19:30',
    checkInTime: '07:18 已签到',
    focusSummary: '先处理 2 个高优先级任务，再跟进 301 房夜间离床告警复核。',
    completionRate: 68,
    urgentAlerts: 2,
  );

  final List<ShiftKpi> shiftKpis = const [
    ShiftKpi(label: '待执行任务', value: '7', caption: '含 2 个 30 分钟内到点'),
    ShiftKpi(label: '重点长者', value: '3', caption: '需复测或重点巡视'),
    ShiftKpi(label: '处理中报警', value: '2', caption: '跌倒 0，呼叫 1，离床 1'),
  ];

  final List<CareTask> todayTasks = const [
    CareTask(
      id: 'task-1',
      title: '晨间生命体征复测',
      residentName: '王秀兰',
      room: '2A-301',
      dueTime: '08:30',
      status: '即将到点',
      priority: 'P1',
      tags: ['血压', '血氧'],
      nextAction: '完成复测后判断是否升级为健康异常。',
      suggestedNotes: ['复测完成，长者主诉平稳', '已同步本次血压与血氧结果'],
    ),
    CareTask(
      id: 'task-2',
      title: '鼻饲护理执行',
      residentName: '陈国富',
      room: '2A-305',
      dueTime: '09:00',
      status: '待执行',
      priority: 'P1',
      tags: ['护理执行', '照片留痕'],
      nextAction: '执行后补录耐受情况和护理备注。',
      evidenceRequirements: [
        CareEvidenceRequirement(
          id: 'feeding-position',
          title: '体位确认照',
          instruction: '拍摄床头抬高后的执行结果，避免带入无关人员或环境。',
          isRequired: true,
        ),
        CareEvidenceRequirement(
          id: 'feeding-supplies',
          title: '器具结果照',
          instruction: '留存鼻饲器具整理完成后的结果状态，便于下一班复核。',
          isRequired: true,
        ),
        CareEvidenceRequirement(
          id: 'comfort-followup',
          title: '舒适度补充照',
          instruction: '如出现轻微不适或需要展示体位垫放，可额外补传一张说明图。',
          isRequired: false,
        ),
      ],
      evidenceFallbackHint: '若长者不适合拍照，请写明原因、执行结果和见证人，避免证据链中断。',
      suggestedNotes: ['鼻饲后耐受良好，无呛咳', '床头已抬高并完成 20 分钟观察提醒', '已向下一班补充反流观察点'],
    ),
    CareTask(
      id: 'task-3',
      title: '康复训练陪护',
      residentName: '周美珍',
      room: '2A-308',
      dueTime: '10:20',
      status: '已分配',
      priority: 'P2',
      tags: ['步态训练'],
      nextAction: '训练前补水，训练后观察心率恢复。',
      suggestedNotes: ['训练完成，心率恢复平稳', '已补水并观察 15 分钟'],
    ),
    CareTask(
      id: 'task-4',
      title: '午前翻身巡视',
      residentName: '李福安',
      room: '2A-312',
      dueTime: '11:10',
      status: '待执行',
      priority: 'P2',
      tags: ['压疮风险'],
      nextAction: '检查皮肤完整性并同步下一班关注点。',
      evidenceRequirements: [
        CareEvidenceRequirement(
          id: 'skin-check',
          title: '皮肤观察照',
          instruction: '仅拍摄压疮风险关注区域的处理结果，注意避开敏感部位与身份信息。',
          isRequired: true,
        ),
      ],
      evidenceFallbackHint: '如因隐私或伤口处理要求不能拍照，请补充皮肤状态描述和复核人。',
      suggestedNotes: ['皮肤完整，无新发红肿', '已完成翻身并同步下一次巡视时间'],
    ),
  ];

  final List<ResidentSnapshot> residents = const [
    ResidentSnapshot(
      id: 'resident-1',
      name: '王秀兰',
      room: '2A-301',
      careLevel: '特护',
      riskNote: '晨起血压偏高，需 30 分钟后复测。',
      lastVitals: '血压 146/92 · 血氧 95%',
      focusTask: '优先完成复测并回写健康解释。',
    ),
    ResidentSnapshot(
      id: 'resident-2',
      name: '陈国富',
      room: '2A-305',
      careLevel: '全护',
      riskNote: '鼻饲后易反流，需要 20 分钟体位观察。',
      lastVitals: '体温 36.6℃ · 心率 78',
      focusTask: '护理执行页补录照片和耐受备注。',
    ),
    ResidentSnapshot(
      id: 'resident-3',
      name: '周美珍',
      room: '2A-308',
      careLevel: '半自理',
      riskNote: '昨日训练后疲劳感偏高，今天控制强度。',
      lastVitals: '心率 81 · 步数 1240',
      focusTask: '康复训练后观察 15 分钟恢复状态。',
    ),
  ];

  late final List<ResidentDetail> residentDetails = [
    ResidentDetail(
      snapshot: residents[0],
      age: '82 岁',
      mobility: '步行需陪同，夜间如厕需提醒',
      cognition: '夜间定向感轻度波动，白天交流清楚',
      dietNote: '低盐软食，早餐后 30 分钟复测前避免情绪波动',
      familyPreference: '家属希望复测后同步结果，并说明是否需要升级为健康异常。',
      watchItems: const [
        '08:30 前完成血压与血氧复测，结果同步到护理站。',
        '结合夜间离床记录，补记是否为自主如厕导致。',
        '若复测仍高于阈值，立即通知护士复核并更新家属解释。',
      ],
      careNotes: const [
        '巡视时先确认床栏复位与呼叫器可触达。',
        '复测后补充主诉，避免只记录数值不记录感受。',
        '不要让 AI 直接替代人工升级判断，结论需责任护工确认。',
      ],
      linkedTaskId: 'task-1',
    ),
    ResidentDetail(
      snapshot: residents[1],
      age: '79 岁',
      mobility: '卧床为主，翻身与鼻饲需双重核对',
      cognition: '表达清晰，但不适主诉容易滞后',
      dietNote: '鼻饲后抬高床头 20 分钟，关注呛咳与反流',
      familyPreference: '家属关注耐受情况和照片留痕，需在护理执行后补充备注。',
      watchItems: const [
        '鼻饲执行后记录耐受、体位与有无反流。',
        '20 分钟观察期内避免立即平躺，重点听取不适主诉。',
        '如触发呼叫按钮，先处理舒适度再补完整事件说明。',
      ],
      careNotes: const [
        '照片留痕仅保留护理动作结果，不拍摄无关画面。',
        '护理备注要写耐受情况，不只写“已完成”。',
        '若出现连续呛咳，优先通知护士，不在本页直接结案。',
      ],
      linkedTaskId: 'task-2',
    ),
    ResidentDetail(
      snapshot: residents[2],
      age: '76 岁',
      mobility: '步态训练可配合，训练后需短时观察',
      cognition: '交流良好，容易因疲劳低估自身消耗',
      dietNote: '训练前补水，训练后 15 分钟内观察心率恢复',
      familyPreference: '家属接受轻量训练方案，但希望避免过度疲劳后再追加任务。',
      watchItems: const [
        '训练前确认主诉与精神状态，再决定是否按原计划执行。',
        '训练后观察 15 分钟心率与疲劳主诉，不适时及时降强度。',
        '交接班时保留恢复状态描述，避免下一班重复加量。',
      ],
      careNotes: const [
        '记录恢复速度和补水情况，作为次日训练依据。',
        '如步态不稳增加，先停止训练并回写风险变化。',
        'AI 只提供训练建议，不直接改写康复计划。',
      ],
      linkedTaskId: 'task-3',
    ),
  ];

  late final List<ResidentHealthView> residentHealthViews = [
    ResidentHealthView(
      residentId: residents[0].id,
      summary: '血压较上次仍偏高，但血氧稳定，复测结果决定是否需要升级异常。',
      riskLevel: '需复测确认',
      nextReview: '08:30 前复测并同步护理站',
      metrics: const [
        HealthMetricTrend(
          label: '血压',
          currentValue: '146/92',
          previousValue: '138/86',
          deltaLabel: '+8 / +6',
          status: '偏高',
          interpretation: '晨起波动明显，需结合主诉与离床记录判断是否升级。',
        ),
        HealthMetricTrend(
          label: '血氧',
          currentValue: '95%',
          previousValue: '96%',
          deltaLabel: '-1%',
          status: '稳定',
          interpretation: '当前未见持续下降，但复测时仍需一起回看。',
        ),
        HealthMetricTrend(
          label: '心率',
          currentValue: '82 bpm',
          previousValue: '78 bpm',
          deltaLabel: '+4',
          status: '可观察',
          interpretation: '轻度升高，重点看是否伴随头晕或不适主诉。',
        ),
      ],
      watchNotes: const [
        '复测前避免长时间交谈或情绪波动，保持相对静息。',
        '把夜间离床原因与复测结果写在同一条护理说明里，避免信息断裂。',
        '如复测仍高，先人工通知护士，再决定是否进入报警链路。',
      ],
    ),
    ResidentHealthView(
      residentId: residents[1].id,
      summary: '当前生命体征平稳，重点不是数值异常，而是鼻饲后耐受与体位观察。',
      riskLevel: '重点观察耐受',
      nextReview: '鼻饲后 20 分钟内完成观察补记',
      metrics: const [
        HealthMetricTrend(
          label: '体温',
          currentValue: '36.6℃',
          previousValue: '36.5℃',
          deltaLabel: '+0.1℃',
          status: '稳定',
          interpretation: '暂未见感染相关变化，继续常规观察。',
        ),
        HealthMetricTrend(
          label: '心率',
          currentValue: '78 bpm',
          previousValue: '80 bpm',
          deltaLabel: '-2',
          status: '平稳',
          interpretation: '数值平稳，仍需结合主诉判断舒适度。',
        ),
        HealthMetricTrend(
          label: '舒适度',
          currentValue: '待补记',
          previousValue: '轻度不适',
          deltaLabel: '待复核',
          status: '待观察',
          interpretation: '执行护理后务必补录主诉与耐受情况。',
        ),
      ],
      watchNotes: const [
        '观察期内优先记录有无呛咳、反流和不适主诉。',
        '照片留痕后补一条文字说明，避免只有图片没有结论。',
        '如再次触发呼叫按钮，先处理舒适度，再更新本页结果。',
      ],
    ),
    ResidentHealthView(
      residentId: residents[2].id,
      summary: '训练后恢复情况是今天重点，需判断是否继续维持轻量训练方案。',
      riskLevel: '训练后复核',
      nextReview: '训练后 15 分钟观察恢复状态',
      metrics: const [
        HealthMetricTrend(
          label: '心率',
          currentValue: '81 bpm',
          previousValue: '84 bpm',
          deltaLabel: '-3',
          status: '回落中',
          interpretation: '较昨日训练后峰值已有回落，但仍需看恢复速度。',
        ),
        HealthMetricTrend(
          label: '步数',
          currentValue: '1240',
          previousValue: '1670',
          deltaLabel: '-430',
          status: '已降强度',
          interpretation: '当前策略符合降强度目标，不建议临时加量。',
        ),
        HealthMetricTrend(
          label: '疲劳主诉',
          currentValue: '偶有疲劳',
          previousValue: '明显疲劳',
          deltaLabel: '减轻',
          status: '改善',
          interpretation: '主诉较昨日改善，但训练后仍需继续复核。',
        ),
      ],
      watchNotes: const [
        '训练前确认精神状态与补水情况，再决定执行时长。',
        '如果出现步态不稳或主诉加重，立即停止并回写变化。',
        '交接班时保留恢复描述，避免下一班误判可加量。',
      ],
    ),
  ];

  final List<AlertCase> alerts = const [
    AlertCase(
      id: 'alert-1',
      title: '夜间离床复核',
      residentName: '王秀兰',
      level: 'P1',
      time: '07:42',
      status: '处理中',
      description: '传感器检测 5 分钟离床，需确认是否因自主如厕导致。',
      recommendedAction: '完成生命体征复测后，补记夜班确认结论。',
      owner: '林晓雯',
    ),
    AlertCase(
      id: 'alert-2',
      title: '呼叫按钮触发',
      residentName: '陈国富',
      level: 'P2',
      time: '08:05',
      status: '待到场',
      description: '床旁呼叫按钮触发，当前未发现二次触发。',
      recommendedAction: '2 分钟内到场，先确认体位与舒适度。',
      owner: '林晓雯',
    ),
    AlertCase(
      id: 'alert-3',
      title: '康复后心率偏高',
      residentName: '周美珍',
      level: 'P3',
      time: '昨天 16:20',
      status: '已结案',
      description: '训练后心率短时升高，休息后已回落。',
      recommendedAction: '今日训练强度维持轻量，并提醒补水。',
      owner: '值班护士 陈晓敏',
    ),
  ];

  final List<NotificationMessage> notifications = const [
    NotificationMessage(
      id: 'msg-1',
      title: '夜班交接已到达',
      body: '王秀兰夜间离床事件需要本班在 09:00 前完成复核。',
      time: '07:25',
      category: '交接班',
      isRead: false,
    ),
    NotificationMessage(
      id: 'msg-2',
      title: '高优先级任务提醒',
      body: '陈国富鼻饲护理已进入执行窗口，完成后需补录耐受情况。',
      time: '07:48',
      category: '任务',
      isRead: false,
    ),
    NotificationMessage(
      id: 'msg-3',
      title: '报警升级建议',
      body: 'AI 建议王秀兰复测后再判断是否升级健康异常。',
      time: '08:00',
      category: '报警',
      isRead: true,
    ),
  ];

  final Map<String, List<AlertTimelineEntry>> alertTimelines = const {
    'alert-1': [
      AlertTimelineEntry(
        time: '07:42',
        title: '设备触发离床报警',
        detail: '301 房床旁离床传感器连续上报 5 分钟离床。',
        actor: 'IoT 设备网关',
      ),
      AlertTimelineEntry(
        time: '07:45',
        title: '夜班护工初查',
        detail: '发现长者已返回床位，初步判断可能为自主如厕。',
        actor: '夜班护工 刘佳',
      ),
      AlertTimelineEntry(
        time: '07:55',
        title: '交接给白班继续复核',
        detail: '要求白班结合血压复测结果决定是否升级健康异常。',
        actor: '系统交接摘要',
      ),
    ],
    'alert-2': [
      AlertTimelineEntry(
        time: '08:05',
        title: '床旁呼叫按钮触发',
        detail: '呼叫按钮单次触发，无二次连续上报。',
        actor: '床旁呼叫设备',
      ),
      AlertTimelineEntry(
        time: '08:06',
        title: '分配责任人',
        detail: '当前事件由责任护工林晓雯到场处理。',
        actor: '报警分派规则',
      ),
    ],
    'alert-3': [
      AlertTimelineEntry(
        time: '昨天 16:20',
        title: '康复后心率偏高',
        detail: '训练结束后心率短时升高到 108 bpm。',
        actor: '康复训练记录',
      ),
      AlertTimelineEntry(
        time: '昨天 16:38',
        title: '人工复核结束',
        detail: '休息与补水后心率恢复到 84 bpm，本次不升级。',
        actor: '值班护士 陈晓敏',
      ),
      AlertTimelineEntry(
        time: '昨天 17:00',
        title: '结案并补充次日建议',
        detail: '次日训练强度下调，并提醒补水。',
        actor: '值班护士 陈晓敏',
      ),
    ],
  };

  final List<HandoverItem> handoverItems = const [
    HandoverItem(
      id: 'handover-1',
      relatedResidentId: 'resident-1',
      residentName: '王秀兰',
      topic: '血压复测结果待确认',
      detail: '若 09:00 前复测仍高于阈值，需通知护士复核。',
      priority: '高',
    ),
    HandoverItem(
      id: 'handover-2',
      relatedResidentId: 'resident-2',
      residentName: '陈国富',
      topic: '鼻饲后观察',
      detail: '留意是否出现呛咳和反流，15 分钟后补记情况。',
      priority: '高',
    ),
    HandoverItem(
      id: 'handover-3',
      relatedResidentId: 'resident-3',
      residentName: '周美珍',
      topic: '康复训练强度控制',
      detail: '今天尽量降低步态训练时长，关注疲劳主诉。',
      priority: '中',
    ),
  ];

  late final List<HandoffDetail> handoffDetails = [
    HandoffDetail(
      item: handoverItems[0],
      owner: '白班责任护工 林晓雯',
      dueBy: '09:00 前完成复测确认',
      lastUpdated: '07:55 夜班交接摘要已生成',
      confirmationSteps: const [
        '确认夜间离床记录是否已和晨间复测绑定到同一对象。',
        '复测后补主诉与人工判断，不只保留数值结论。',
        '若仍高于阈值，通知护士并保留升级时间点。',
      ],
      escalationNote: '本项允许 AI 生成解释草稿，但是否升级健康异常必须由责任护工或护士确认。',
    ),
    HandoffDetail(
      item: handoverItems[1],
      owner: '白班责任护工 林晓雯',
      dueBy: '鼻饲后 20 分钟内补完观察结果',
      lastUpdated: '07:48 高优先级任务已进入执行窗口',
      confirmationSteps: const [
        '执行后先记录体位、耐受与有无呛咳。',
        '如出现不适主诉，先通知护士再完善交接语句。',
        '照片留痕后补文字说明，避免只看图片无法追责。',
      ],
      escalationNote: '本项默认不自动结案；若有反流或连续呛咳，应走人工复核与护士通知链路。',
    ),
    HandoffDetail(
      item: handoverItems[2],
      owner: '康复陪护责任护工 林晓雯',
      dueBy: '交接前补充训练后恢复情况',
      lastUpdated: '昨日 17:00 已写入次日轻量训练建议',
      confirmationSteps: const [
        '训练前确认是否仍需维持降强度计划。',
        '训练后 15 分钟观察心率恢复与疲劳主诉。',
        '在交接摘要中保留“是否可以恢复原强度”的人工判断。',
      ],
      escalationNote: 'AI 可生成交接草稿，但不能直接改写康复计划或替代主管确认。',
    ),
  ];

  final List<ScheduleItem> schedule = const [
    ScheduleItem(
      date: '03-30 周一',
      shift: '白班 07:30 - 19:30',
      area: '2号楼 A 区',
      note: '主责王秀兰、陈国富两位重点对象。',
    ),
    ScheduleItem(
      date: '03-31 周二',
      shift: '白班 07:30 - 19:30',
      area: '2号楼 A 区',
      note: '继续执行康复训练陪护。',
    ),
    ScheduleItem(
      date: '04-01 周三',
      shift: '夜班 19:30 - 07:30',
      area: '2号楼 B 区',
      note: '跨区支援，调班需主管确认。',
    ),
  ];

  final List<VitalDraft> vitalDrafts = const [
    VitalDraft(
      label: '血压',
      unit: 'mmHg',
      placeholder: '例如 132/84',
      lastValue: '146/92',
    ),
    VitalDraft(
      label: '心率',
      unit: 'bpm',
      placeholder: '例如 78',
      lastValue: '81',
    ),
    VitalDraft(
      label: '血氧',
      unit: '%',
      placeholder: '例如 96',
      lastValue: '95',
    ),
    VitalDraft(
      label: '体温',
      unit: '℃',
      placeholder: '例如 36.5',
      lastValue: '36.6',
    ),
  ];

  final List<AiInsight> aiInsights = const [
    AiInsight(
      title: '班次摘要建议',
      summary: '建议把王秀兰复测放在 08:30 前完成，再安排陈国富鼻饲护理。',
      reason: '当前存在健康异常复核时限，且鼻饲任务需要完整连续操作。',
      action: '先复测，再执行护理，并同步夜班结论。',
    ),
    AiInsight(
      title: '报警响应建议',
      summary: '呼叫按钮触发优先到场，但不自动关闭夜间离床事件。',
      reason: '报警与历史风险需要独立留痕，不能合并结案。',
      action: '先到场，再回补两条事件的人工判断记录。',
    ),
    AiInsight(
      title: '交接班草稿',
      summary: '重点关注王秀兰血压复测结论和陈国富鼻饲后耐受。',
      reason: '这两项都直接影响下一班巡视频率和升级判断。',
      action: '生成交接草稿后仍需主管或责任护工确认。',
    ),
  ];

  final String aiBoundary =
      'AI 只负责摘要、解释和动作建议，不自动改写责任人、不自动结案，也不直接执行医疗操作。';

  final String handoverSummary =
      '本班重点是复测、鼻饲后观察和康复训练降强度。交接班时必须保留责任人、时间点和人工确认结论。';

  CareTask findTaskById(String taskId) {
    return todayTasks.firstWhere(
      (task) => task.id == taskId,
      orElse: () => todayTasks.first,
    );
  }

  ResidentSnapshot findResidentById(String residentId) {
    return residents.firstWhere(
      (resident) => resident.id == residentId,
      orElse: () => residents.first,
    );
  }

  ResidentDetail findResidentDetailById(String residentId) {
    return residentDetails.firstWhere(
      (detail) => detail.snapshot.id == residentId,
      orElse: () => residentDetails.first,
    );
  }

  ResidentHealthView findResidentHealthViewById(String residentId) {
    return residentHealthViews.firstWhere(
      (view) => view.residentId == residentId,
      orElse: () => residentHealthViews.first,
    );
  }

  int findResidentIndexById(String residentId) {
    final index = residents.indexWhere((resident) => resident.id == residentId);
    return index >= 0 ? index : 0;
  }

  HandoverItem findHandoverItemById(String handoverId) {
    return handoverItems.firstWhere(
      (item) => item.id == handoverId,
      orElse: () => handoverItems.first,
    );
  }

  HandoffDetail findHandoffDetailById(String handoverId) {
    return handoffDetails.firstWhere(
      (detail) => detail.item.id == handoverId,
      orElse: () => handoffDetails.first,
    );
  }

  AlertCase findAlertById(String alertId) {
    return alerts.firstWhere(
      (alert) => alert.id == alertId,
      orElse: () => alerts.first,
    );
  }

  List<AlertTimelineEntry> findAlertTimeline(String alertId) {
    return alertTimelines[alertId] ?? const [];
  }

  int get unreadNotificationCount {
    return notifications.where((message) => !message.isRead).length;
  }

  CareClockInDraft? findClockInDraft(String taskId) {
    return _clockInDrafts[taskId];
  }

  CareClockInDraft saveClockInDraft(CareClockInDraft draft) {
    _clockInDrafts[draft.taskId] = draft;
    return draft;
  }
}