import Testing
@testable import ReaderModels

@Suite("段评标记解析")
struct ParagraphCommentTests {
    /// 服务器下发的 text 形态标记：para 只在 onPress 地址里，参数间是 &amp; 实体转义
    @Test("onPress 地址里的 &amp; 被反转义，para 不丢")
    func escapedOnPressURL() {
        let line = "正文一段。<comment count=\"24\" onPress=\"java.showReadingBrowser('https://api.aiyunsy.com/comment?source=%E7%95%AA%E8%8C%84%E5%B0%8F%E8%AF%B4&amp;tab=paras&amp;book_id=7001&amp;item_id=7002&amp;para=3','番茄段评')\"></comment>"
        let (text, comment) = ParagraphComment.extract(from: line)
        #expect(text == "正文一段。")
        #expect(comment?.count == "24")
        let action = comment?.action ?? ""
        #expect(action.contains("source=%E7%95%AA%E8%8C%84%E5%B0%8F%E8%AF%B4&tab=paras&book_id=7001&item_id=7002&para=3"))
        #expect(!action.contains("&amp;"))
    }

    /// 原始标记：ident 是评论页地址，段落序号在单独的 para 属性里
    @Test("ident 兜底时把 para 属性补回地址")
    func identFallbackAddsPara() {
        let line = "正文二段。<comment ident=\"https://api.aiyunsy.com/comment?source=%E7%95%AA&amp;tab=paras&amp;book_id=7001&amp;item_id=7002\" para=\"5\" count=\"9\">正文二段。</comment>"
        let (_, comment) = ParagraphComment.extract(from: line)
        #expect(comment?.count == "9")
        #expect(comment?.action?.contains("&para=5") == true)
    }

    @Test("没有标记时原样返回")
    func noMarker() {
        let (text, comment) = ParagraphComment.extract(from: "普通一段，没有标记。")
        #expect(text == "普通一段，没有标记。")
        #expect(comment == nil)
    }
}
