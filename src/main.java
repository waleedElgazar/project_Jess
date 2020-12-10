import java.awt.EventQueue;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import java.awt.Font;
import java.awt.Color;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.JLabel;
import javax.swing.ImageIcon;
import jess.JessException;
import jess.Rete;

public class main extends JFrame {
    private JPanel contentPane;
    public static void main(String[] args) {
        EventQueue.invokeLater(new Runnable() {
            public void run() {
                try {
                    main frame = new main();
                    frame.setVisible(true);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }
    public main() {
        setBackground(Color.WHITE);
        setFont(new Font("Rockwell Condensed", Font.BOLD, 22));
        setResizable(false);
        setTitle("Health care Assistant");
        setLocationRelativeTo(null);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setBounds(100, 100, 403, 297);
        contentPane = new JPanel();
        contentPane.setBackground(Color.WHITE);
        contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
        setContentPane(contentPane);
        contentPane.setLayout(null);
        JButton btnOpenTheProject = new JButton("Start Asking Our Expert System");
        btnOpenTheProject.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        Rete r = new Rete();
                        try {
                            r.batch("rules.clp");
                        } catch (JessException ex) {
                            ex.printStackTrace();
                        }
                    }
                }).start();
            }
        });
        btnOpenTheProject.setFont(new Font("Rockwell Condensed", Font.BOLD, 22));
        btnOpenTheProject.setBounds(10, 139, 367, 50);
        contentPane.add(btnOpenTheProject);
        JLabel lblNewLabel = new JLabel("");
        lblNewLabel.setBounds(120, 0, 128, 128);
        contentPane.add(lblNewLabel);
    }
}
