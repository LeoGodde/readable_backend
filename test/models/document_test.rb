require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "documento válido deve ser salvo" do
    document = Document.new(
      username: "teste",
      html_content: "<p>Teste</p>"
    )
    assert document.valid?, "Documento deveria ser válido"
    assert document.save, "Documento deveria ser salvo"
  end

  test "documento sem username nao deve ser válido" do
    document = Document.new(
      html_content: "<p>Teste</p>"
    )
    assert_not document.valid?, "Documento sem username não deveria ser válido"
    assert_includes document.errors[:username], "can't be blank"
  end

  test "documento sem html_content nao deve ser válido" do
    document = Document.new(
      username: "teste"
    )
    assert_not document.valid?, "Documento sem html_content não deveria ser válido"
    assert_includes document.errors[:html_content], "can't be blank"
  end

  test "documento deve ser salvo com timestamps" do
    document = Document.create!(
      username: "teste",
      html_content: "<p>Teste</p>"
    )
    assert_not_nil document.created_at
    assert_not_nil document.updated_at
  end
end
