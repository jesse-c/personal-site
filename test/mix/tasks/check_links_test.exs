defmodule Mix.Tasks.CheckLinksTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.CheckLinks

  describe "extract_internal_links/1" do
    test "extracts blog post slugs from internal links" do
      html = """
      <a href="/blog/my-post">Internal</a>
      <a href="/blog/another-post">Internal 2</a>
      """

      assert CheckLinks.extract_internal_links(html) == ["my-post", "another-post"]
    end

    test "ignores external links" do
      html = """
      <a href="https://example.com">External</a>
      <a href="http://github.com">External 2</a>
      """

      assert CheckLinks.extract_internal_links(html) == []
    end

    test "ignores non-blog internal links" do
      html = """
      <a href="/about">About</a>
      <a href="/projects">Projects</a>
      """

      assert CheckLinks.extract_internal_links(html) == []
    end

    test "extracts only blog links from mixed content" do
      html = """
      <a href="/blog/first-post">Blog Post</a>
      <a href="https://example.com">External</a>
      <a href="/about">About</a>
      <a href="/blog/second-post">Another Post</a>
      """

      assert CheckLinks.extract_internal_links(html) == ["first-post", "second-post"]
    end

    test "handles empty string" do
      assert CheckLinks.extract_internal_links("") == []
    end

    test "handles links with query parameters and fragments" do
      html = """
      <a href="/blog/my-post?ref=twitter">With query</a>
      <a href="/blog/another-post#section">With fragment</a>
      """

      assert CheckLinks.extract_internal_links(html) == [
               "my-post?ref=twitter",
               "another-post#section"
             ]
    end

    test "extracts relative slug-like links" do
      html = """
      <a href="my-post-slug">Relative</a>
      <a href="another-slug-here">Another</a>
      """

      assert CheckLinks.extract_internal_links(html) == ["my-post-slug", "another-slug-here"]
    end

    test "ignores fragment-only links" do
      html = """
      <a href="#section">Section</a>
      """

      assert CheckLinks.extract_internal_links(html) == []
    end

    test "combines relative and absolute blog links" do
      html = """
      <a href="relative-slug">Relative</a>
      <a href="/blog/absolute-slug">Absolute</a>
      <a href="another-relative">Another</a>
      """

      assert CheckLinks.extract_internal_links(html) == [
               "relative-slug",
               "another-relative",
               "absolute-slug"
             ]
    end

    test "ignores slugs with uppercase letters" do
      html = """
      <a href="MyPost">Uppercase</a>
      <a href="valid-slug">Valid</a>
      """

      assert CheckLinks.extract_internal_links(html) == ["valid-slug"]
    end

    test "ignores slugs with special characters" do
      html = """
      <a href="post_with_underscores">Underscores</a>
      <a href="post.with.dots">Dots</a>
      <a href="valid-slug-123">Valid</a>
      """

      assert CheckLinks.extract_internal_links(html) == ["valid-slug-123"]
    end

    test "handles slugs with numbers" do
      html = """
      <a href="post-123">With numbers</a>
      <a href="2024-update">Starting with number</a>
      """

      assert CheckLinks.extract_internal_links(html) == ["post-123", "2024-update"]
    end
  end

  describe "extract_absolute_blog_links/1" do
    test "extracts /blog/ links" do
      html = """
      <a href="/blog/first-post">First</a>
      <a href="/blog/second-post">Second</a>
      """

      assert CheckLinks.extract_absolute_blog_links(html) == [
               "/blog/first-post",
               "/blog/second-post"
             ]
    end

    test "ignores relative slugs" do
      html = """
      <a href="relative-slug">Relative</a>
      <a href="another-slug">Another</a>
      """

      assert CheckLinks.extract_absolute_blog_links(html) == []
    end

    test "ignores external and other internal links" do
      html = """
      <a href="https://example.com">External</a>
      <a href="/about">About</a>
      <a href="/projects">Projects</a>
      """

      assert CheckLinks.extract_absolute_blog_links(html) == []
    end

    test "extracts only /blog/ links from mixed content" do
      html = """
      <a href="/blog/first-post">Blog</a>
      <a href="relative-slug">Relative</a>
      <a href="https://example.com">External</a>
      <a href="/about">About</a>
      <a href="/blog/second-post">Another Blog</a>
      """

      assert CheckLinks.extract_absolute_blog_links(html) == [
               "/blog/first-post",
               "/blog/second-post"
             ]
    end

    test "handles empty string" do
      assert CheckLinks.extract_absolute_blog_links("") == []
    end

    test "extracts /blog/ links with query params and fragments" do
      html = """
      <a href="/blog/post?ref=twitter">With query</a>
      <a href="/blog/another#section">With fragment</a>
      """

      assert CheckLinks.extract_absolute_blog_links(html) == [
               "/blog/post?ref=twitter",
               "/blog/another#section"
             ]
    end
  end
end
